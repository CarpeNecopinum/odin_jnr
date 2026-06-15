#+feature dynamic-literals

package main

import "vendor:raylib"

GameState :: struct {
	size:  [2]i32,
	shift: [2]i32,
}


main :: proc() {
	raylib.SetConfigFlags({.VSYNC_HINT})
	raylib.InitWindow(800, 346, "Odin J&N")
	gs := GameState{{800, 346}, {0, 0}}

	bg := loadDefaultBackground()

	for !raylib.WindowShouldClose() {
		raylib.PollInputEvents()
		if raylib.IsKeyDown(.LEFT) {
			gs.shift.x -= 5
		} else if raylib.IsKeyDown(.RIGHT) {
			gs.shift.x += 5
		}

		if raylib.IsKeyDown(.UP) {
			gs.shift.y -= 5
		} else if raylib.IsKeyDown(.DOWN) {
			gs.shift.y += 5
		}

		raylib.BeginDrawing()
		drawBackground(bg, gs)
		raylib.EndDrawing()
	}
	raylib.CloseWindow()
}
