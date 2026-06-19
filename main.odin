#+feature dynamic-literals

package main

import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math"
import "vendor:box2d"
import "vendor:raylib"

Camera :: struct {
	size:   [2]i32,
	origin: [2]i32,
	scale:  i32,
}

GameState :: struct {
	camera: Camera,
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

makePlayerBody :: proc(w: box2d.WorldId, p: Character) -> box2d.BodyId {
	frame_size := p.animations[.IDLE].frame_size
	bodyDef := box2d.DefaultBodyDef()
	bodyDef.type = .dynamicBody
	bodyDef.position.x = f32(p.pos.x + frame_size.x / 2)
	bodyDef.position.y = f32(p.pos.y + frame_size.y / 3)
	bodyId := box2d.CreateBody(w, bodyDef)

	box := box2d.MakeOffsetBox(
		f32(frame_size.x / 8),
		f32(frame_size.y / 3),
		([2]f32){0, f32(frame_size.y / 6)},
		box2d.Rot_identity,
	)
	shapeDef := box2d.DefaultShapeDef()
	shapeDef.material.friction = 0.1
	_ = box2d.CreatePolygonShape(bodyId, shapeDef, box)

	return bodyId
}

applyInputForces :: proc(pb: box2d.BodyId) {
	force := [2]f32{}

	mass := box2d.Body_GetMass(pb)
	if raylib.IsKeyDown(.LEFT) {
		force.x = -200 * mass
	} else if raylib.IsKeyDown(.RIGHT) {
		force.x = 200 * mass
	}

	vel := box2d.Body_GetLinearVelocity(pb)
	if raylib.IsKeyDown(.UP) && math.abs(vel.y) < 10 {
		fmt.println("Jumped")
		box2d.Body_ApplyLinearImpulseToCenter(pb, {0.0, -200.0 * mass}, true)
	}

	box2d.Body_ApplyForceToCenter(pb, force, true)

	torque_factor := 9000 * mass
	rot := box2d.Body_GetRotation(pb)
	box2d.Body_ApplyTorque(pb, -torque_factor * box2d.Rot_GetAngle(rot), true)
}
updatePlayer :: proc(p: ^Character, pb: box2d.BodyId) {
	p.frame_idx += 1

	frame_size := p.animations[.IDLE].frame_size
	p.pos = ([2]i32)(box2d.Body_GetPosition(pb)) - frame_size / 2
	rot := box2d.Body_GetRotation(pb)
	p.rot = math.atan2(rot.s, rot.c)

	vel := box2d.Body_GetLinearVelocity(pb)
	if vel.x > 10 {
		p.facing = .RIGHT
		p.state = .WALKING
	} else if vel.x < -10 {
		p.facing = .LEFT
		p.state = .WALKING
	} else {
		p.state = .IDLE
	}
}


main :: proc() {
	raylib.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE})
	raylib.InitWindow(800, 600, "Odin J&N")
	gs := GameState{{{800, 600}, {0, 0}, 2}}

	bg := loadDefaultBackground()

	game_map := loadMap("maps/intro.tmj")
	pworld_def := box2d.DefaultWorldDef()
	pworld_def.gravity.y = 500
	pworld := box2d.CreateWorld(pworld_def)
	defer box2d.DestroyWorld(pworld)
	physicalizeWorld(game_map, pworld)

	p := makePlayer()
	{
		spawn := findMapObject(game_map, "Spawn")
		p.pos.x = spawn.x - p.animations[.IDLE].frame_size.x / 2
		p.pos.y = spawn.y - p.animations[.IDLE].frame_size.y
		p.pos.y -= 100
	}
	pbody := makePlayerBody(pworld, p)

	dd := box2d.DefaultDebugDraw()
	dd.DrawSolidPolygonFcn = proc "c" (
		transform: box2d.Transform,
		vertices: [^][2]f32,
		count: i32,
		radius: f32,
		color: box2d.HexColor,
		ctx: rawptr,
	) {
		gs := (^GameState)(ctx)
		c := (raylib.Color)(i32(color) << 2 | 0xff)
		vtcs := [16][2]f32{}
		for i in 0 ..< count {
			global := box2d.TransformPoint(transform, vertices[i])
			vtcs[i] = ([2]f32)(([2]i32)(global) * gs.camera.scale - gs.camera.origin)
		}
		vtcs[count] = vtcs[0]
		// raylib.DrawCircle(i32(vtcs[0].x), i32(vtcs[0].y), 10, raylib.WHITE)
		raylib.DrawLineStrip(&vtcs[0], count + 1, raylib.WHITE)
		{
			context = runtime.default_context()
			fmt.println(vtcs[0], count)
		}
	}
	dd.drawShapes = true
	dd.userContext = &gs

	for !raylib.WindowShouldClose() {
		if raylib.IsWindowResized() {
			new_size := [2]i32{raylib.GetRenderWidth(), raylib.GetRenderHeight()}
			delta := new_size - gs.camera.size
			gs.camera.size = new_size
			gs.camera.origin -= delta / 2
		}

		raylib.PollInputEvents()

		applyInputForces(pbody)
		box2d.World_Step(pworld, 1 / 60.0, 4)

		updatePlayer(&p, pbody)
		focusCharacter(&gs.camera, p)

		raylib.BeginDrawing()
		drawBackground(bg, gs)
		drawTileMap(game_map, gs)

		drawCharacter(p, gs)

		raylib.DrawCircle(1, 1, 1.0, raylib.WHITE)
		// box2d.World_Draw(pworld, &dd)

		raylib.EndDrawing()
	}
	raylib.CloseWindow()
}
