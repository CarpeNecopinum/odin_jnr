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

		raylib.BeginDrawing()
		drawBackground(bg, gs)
		drawTileMap(game_map, gs)
		raylib.EndDrawing()
	}
	raylib.CloseWindow()
}
