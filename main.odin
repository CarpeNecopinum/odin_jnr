#+feature dynamic-literals

package main

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
	moveCharacterToObject(&p, findMapObject(game_map, "Spawn")^)
	pbody := makePlayerBody(pworld, p)

	dd := makeDebugDraw(&gs)

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
		box2d.World_Draw(pworld, &dd)

		raylib.EndDrawing()
	}
	raylib.CloseWindow()
}
