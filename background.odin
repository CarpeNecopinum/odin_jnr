#+feature dynamic-literals
package main

import "vendor:raylib"

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

loadDefaultBackground :: proc() -> Background {
	return Background {
		{
			raylib.LoadTexture("assets/gh_platform/bgs/normal/layer5.png"),
			raylib.LoadTexture("assets/gh_platform/bgs/normal/layer4.png"),
			raylib.LoadTexture("assets/gh_platform/bgs/normal/layer3.png"),
			raylib.LoadTexture("assets/gh_platform/bgs/normal/layer2.png"),
			raylib.LoadTexture("assets/gh_platform/bgs/normal/layer1.png"),
		},
	}
}
