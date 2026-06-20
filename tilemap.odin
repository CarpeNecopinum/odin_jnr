package main

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "vendor:box2d"
import "vendor:raylib"

MapChunk :: struct {
	width:  i32,
	height: i32,
	x:      i32,
	y:      i32,
	data:   [dynamic]u16,
}

MapObject :: struct {
	id:   i32,
	name: string,
	x, y: i32,
}

LayerType :: enum {
	objectgroup,
	tilelayer,
}

MapLayer :: struct {
	type:    LayerType,
	name:    string,
	chunks:  [dynamic]MapChunk,
	objects: [dynamic]MapObject,
}

TileSet :: struct {
	columns:    i32,
	firstgid:   i32,
	image:      string,
	tilewidth:  i32,
	tileheight: i32,
	tilecount:  i32,
}

RenderTile :: struct {
	texture: raylib.Texture2D,
	x:       i32,
	y:       i32,
}

TileMap :: struct {
	layers:     [dynamic]MapLayer,
	tilesets:   [dynamic]TileSet,
	tiles:      [dynamic]RenderTile,
	tilewidth:  i16,
	tileheight: i16,
}

loadMap :: proc(filename: string) -> TileMap {
	defer free_all(context.temp_allocator)

	folder := filepath.dir(filename)

	raw_data, err := os.read_entire_file(filename, context.temp_allocator)
	if err != nil do panic(fmt.aprintf("Could not load map from %s - %s", filename, err))

	mappe := TileMap{}
	json.unmarshal(raw_data, &mappe) // no temp_allocator, because we need this later

	max_idx: i32 = 0
	for set in mappe.tilesets {
		max_idx = max(max_idx, set.firstgid + set.tilecount)
	}
	mappe.tiles = make([dynamic]RenderTile, max_idx + 1)
	for set in mappe.tilesets {
		image_path, _ := filepath.join({folder, set.image}, context.temp_allocator)
		image_cstring := strings.clone_to_cstring(image_path, context.temp_allocator)

		tex := raylib.LoadTexture(image_cstring)
		for i in 0 ..< set.tilecount {
			x := (i % set.columns) * set.tilewidth
			y := (i / set.columns) * set.tileheight
			idx := set.firstgid + i
			mappe.tiles[idx] = {tex, x, y}
		}
	}
	return mappe
}


drawTileMap :: proc(m: TileMap, gs: GameState) {
	white := raylib.Color{255, 255, 255, 255}
	make_rect :: proc(x, y: i32, w, h: i16) -> raylib.Rectangle {
		return {f32(x), f32(y), f32(w), f32(h)}
	}

	// shift := gs.camera.origin
	// scale := gs.camera.scale
	for layer in m.layers {
		if layer.type != .tilelayer do continue
		for c in layer.chunks {
			for i in 0 ..< (c.width * c.height) {
				tile_idx := c.data[i]
				if tile_idx == 0 do continue

				pos := [2]i32 {
					i32(m.tilewidth) * (i % c.width) + (c.x * i32(m.tilewidth)),
					i32(m.tileheight) * (i / c.width) + (c.y * i32(m.tileheight)),
				}
				// pos *= scale
				// pos -= shift

				tile := m.tiles[tile_idx]
				raylib.DrawTexturePro(
					tile.texture,
					make_rect(tile.x, tile.y, m.tilewidth, m.tileheight),
					make_rect(pos.x, pos.y, m.tilewidth, m.tileheight),
					raylib.Vector2{},
					0.0,
					white,
				)
			}
		}
	}
}

findMapObject :: proc(m: TileMap, name: string) -> ^MapObject {
	for l in m.layers {
		if l.type != .objectgroup do continue
		for &o in l.objects {
			if o.name == name do return &o
		}
	}
	return nil
}

findMapLayer :: proc(m: TileMap, name: string) -> ^MapLayer {
	for &l in m.layers {
		if l.name == name do return &l
	}
	return nil
}

physicalizeWorld :: proc(m: TileMap, w: box2d.WorldId) -> box2d.BodyId {
	layer := findMapLayer(m, "Physical")
	bodyDef := box2d.DefaultBodyDef()
	bodyDef.type = .staticBody
	bodyId := box2d.CreateBody(w, bodyDef)

	halfWidth, halfHeight := f32(m.tilewidth / 2), f32(m.tileheight / 2)
	shapeDef := box2d.DefaultShapeDef()
	for c in layer.chunks {
		for row in 0 ..< c.height {
			for col in 0 ..< c.width {
				idx := col + row * c.width
				if c.data[idx] == 0 do continue

				center := [2]f32 {
					f32((col + c.x) * i32(m.tilewidth)) + halfWidth,
					f32((row + c.y) * i32(m.tileheight)) + halfHeight,
				}
				box := box2d.MakeOffsetBox(halfWidth, halfHeight, center, box2d.Rot_identity)
				_ = box2d.CreatePolygonShape(bodyId, shapeDef, box)
			}
		}
	}
	return bodyId
}
