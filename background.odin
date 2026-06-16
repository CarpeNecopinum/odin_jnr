#+feature dynamic-literals
package main

import "vendor:raylib"

Background :: struct {
	layers: [dynamic]raylib.Texture2D,
	scale:  i32,
}

drawTilingX :: proc(tex: raylib.Texture2D, x: i32, y: i32, width: i32, scale: i32) {
	wscaled := tex.width * scale
	xreal := x % wscaled - wscaled
	white := raylib.Color{255, 255, 255, 255}
	for draw_x := xreal; draw_x <= width; draw_x += wscaled {
		raylib.DrawTextureEx(tex, {f32(draw_x), f32(y)}, 0.0, f32(scale), white)
	}
}

drawBackground :: proc(bg: Background, state: GameState) {
	for tex, idx in bg.layers {
		parallax := 1.0 / f32(len(bg.layers) + 1 - idx)
		parallaxed_shift := ([2]i32)(([2]f32)(-state.camera.origin) * parallax)
		drawTilingX(tex, parallaxed_shift.x, parallaxed_shift.y, state.camera.size.x, bg.scale)
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
		4,
	}
}
