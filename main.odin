#+feature dynamic-literals

package main

import "core:fmt"
import "vendor:box2d"
import "vendor:raylib"

Camera :: struct {
	size:   [2]i32,
	origin: [2]i32,
	scale:  i32,
}

GameState :: struct {
	camera: raylib.Camera2D,
}

controlCamera :: proc(c: ^raylib.Camera2D) {
	if raylib.IsKeyDown(.KP_ADD) {
		c.zoom *= 1.1
	} else if raylib.IsKeyDown(.KP_SUBTRACT) {
		c.zoom /= 1.1
	}
}

main :: proc() {
	raylib.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE})
	raylib.InitWindow(800, 600, "Odin J&N")
	gs := GameState{raylib.Camera2D{{400, 300}, {}, 0.0, 1.0}}

	bg := loadDefaultBackground()

	game_map := loadMap("maps/intro.tmj")
	pworld_def := box2d.DefaultWorldDef()
	pworld_def.gravity.y = 500
	pworld := box2d.CreateWorld(pworld_def)
	defer box2d.DestroyWorld(pworld)
	physicalizeWorld(game_map, pworld)

	p := makePlayer()
	moveCharacterToObject(&p, findMapObject(game_map, "Spawn")^)
	pbody := makePlayerBody(pworld, p)

	dd := makeDebugDraw(&gs)

	for !raylib.WindowShouldClose() {

		if raylib.IsWindowResized() {
			gs.camera.offset = [2]f32 {
				f32(raylib.GetRenderWidth()) / 2.0,
				f32(raylib.GetRenderHeight()) / 2.0,
			}
		}

		raylib.PollInputEvents()

		controlCamera(&gs.camera)
		applyInputForces(pbody)
		box2d.World_Step(pworld, 1 / 60.0, 4)

		updatePlayer(&p, pbody)
		focusCharacter(&gs.camera, p)

		raylib.BeginDrawing()
		drawBackground(bg, gs)
		raylib.BeginMode2D(gs.camera)
		drawTileMap(game_map, gs)

		drawCharacter(p, gs)

		raylib.DrawCircle(1, 1, 1.0, raylib.WHITE) // somehow, debug rendering only works when we've drawn a circle before it
		box2d.World_Draw(pworld, &dd)

		raylib.EndMode2D()
		raylib.EndDrawing()
	}
	raylib.CloseWindow()
}
