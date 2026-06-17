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


		updatePlayer(&p)
		focusCharacter(&gs.camera, p)

		raylib.BeginDrawing()
		drawBackground(bg, gs)
		drawTileMap(game_map, gs)
		drawCharacter(p, gs)
		raylib.EndDrawing()
	}
	raylib.CloseWindow()
}
