#+feature dynamic-literals

package main

import "core:fmt"
import "vendor:raylib"

Camera :: struct {
	size:   [2]i32,
	origin: [2]i32,
	scale:  i32,
}

GameState :: struct {
	camera: Camera,
}

Facing :: enum {
	LEFT  = 0,
	RIGHT = 1,
}

CharacterState :: enum {
	IDLE,
	WALKING,
	// RUNNING,
	// FLYING,
	// JUMPING,
	// HITTING,
	// DYING,
}

Animation :: struct {
	y:          i32,
	frame_size: [2]i32,
	num_frames: i32,
}

Player :: struct {
	pos:           [2]i32,
	texture:       raylib.Texture,
	facing:        Facing,
	state:         CharacterState,
	animations:    [CharacterState]Animation,
	frame_idx:     i32,
	frame_divisor: i32,
}

makePlayer :: proc() -> Player {
	return {
		{0, 0},
		raylib.LoadTexture("assets/gh_chars/Character skin colors/Female Skin1.png"),
		.LEFT,
		.IDLE,
		{.IDLE = {0, {80, 64}, 5}, .WALKING = {64, {80, 64}, 8}},
		0,
		6,
	}
}

updatePlayer :: proc(p: ^Player) {
	p.frame_idx += 1
}

drawPlayer :: proc(p: Player, gs: GameState) {
	make_rect :: proc(pos: [2]i32, size: [2]i32) -> raylib.Rectangle {
		return {f32(pos.x), f32(pos.y), f32(size.x), f32(size.y)}
	}

	anim := p.animations[p.state]
	frame_idx := (p.frame_idx / p.frame_divisor) % anim.num_frames
	src := [2]i32{frame_idx * anim.frame_size.x, anim.y}
	raylib.DrawTexturePro(
		p.texture,
		make_rect(src, anim.frame_size),
		make_rect(p.pos * gs.camera.scale, anim.frame_size * gs.camera.scale),
		([2]f32)(gs.camera.origin),
		0,
		raylib.Color{255, 255, 255, 255},
	)
}

main :: proc() {
	raylib.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE})
	raylib.InitWindow(800, 600, "Odin J&N")
	gs := GameState{{{800, 600}, {0, 0}, 2}}

	bg := loadDefaultBackground()

	game_map := loadMap("maps/intro.tmj")
	p := makePlayer()
	{
		spawn := findMapObject(game_map, "Spawn")
		p.pos.x = spawn.x - p.animations[.IDLE].frame_size.x / 2
		p.pos.y = spawn.y - p.animations[.IDLE].frame_size.y
	}

	for !raylib.WindowShouldClose() {
		if raylib.IsWindowResized() {
			new_size := [2]i32{raylib.GetRenderWidth(), raylib.GetRenderHeight()}
			delta := new_size - gs.camera.size
			gs.camera.size = new_size
			gs.camera.origin -= delta / 2
		}

		raylib.PollInputEvents()
		cam := &gs.camera
		if raylib.IsKeyDown(.LEFT) {
			cam.origin.x -= 5
		} else if raylib.IsKeyDown(.RIGHT) {
			cam.origin.x += 5
		}

		if raylib.IsKeyDown(.UP) {
			cam.origin.y -= 5
		} else if raylib.IsKeyDown(.DOWN) {
			cam.origin.y += 5
		}

		updatePlayer(&p)

		raylib.BeginDrawing()
		drawBackground(bg, gs)
		drawTileMap(game_map, gs)
		drawPlayer(p, gs)
		raylib.EndDrawing()
	}
	raylib.CloseWindow()
}
