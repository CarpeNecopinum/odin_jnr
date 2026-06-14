#+feature dynamic-literals

package main

import "vendor:raylib"

GameState :: struct {
	size:  [2]i32,
	shift: [2]i32,
}

Background :: struct {
	layers: [dynamic]raylib.Texture2D,
}

drawTilingX :: proc(tex: raylib.Texture2D, x: i32, y: i32, width: i32) {
	xreal := x % tex.width - tex.width
	white := raylib.Color{255, 255, 255, 255}
	for draw_x := xreal; draw_x <= width; draw_x += tex.width {
		raylib.DrawTexture(tex, draw_x, y, white)
	}
}

drawBackground :: proc(bg: Background, state: GameState) {
	for tex, idx in bg.layers {
		scale := 1.0 / f32(len(bg.layers) + 1 - idx)
		drawTilingX(
			tex,
			i32(f32(-state.shift.x) * scale),
			i32(f32(-state.shift.y) * scale),
			state.size.x,
		)
	}
}

main :: proc() {
	raylib.SetConfigFlags({.VSYNC_HINT})
	raylib.InitWindow(800, 346, "Odin J&N")
	gs := GameState{{800, 346}, {0, 0}}

	bg := Background {
		{
			raylib.LoadTexture("assets/gh_platform/bgs/normal/layer5.png"),
			raylib.LoadTexture("assets/gh_platform/bgs/normal/layer4.png"),
			raylib.LoadTexture("assets/gh_platform/bgs/normal/layer3.png"),
			raylib.LoadTexture("assets/gh_platform/bgs/normal/layer2.png"),
			raylib.LoadTexture("assets/gh_platform/bgs/normal/layer1.png"),
		},
	}

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
