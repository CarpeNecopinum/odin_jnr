package main

import "vendor:raylib"

main :: proc() {
	raylib.InitWindow(800, 600, "Odin J&N")
	for !raylib.WindowShouldClose() {
		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.Color({64, 64, 64, 255}))
		raylib.EndDrawing()
	}
	raylib.CloseWindow()
}
