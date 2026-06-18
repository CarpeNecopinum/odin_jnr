package main

import "core:strings"
import "vendor:raylib"
import "vendor:raylib/rlgl"

gutRenderTexture :: proc(t: raylib.RenderTexture) -> raylib.Texture {
	if (t.id > 0) do rlgl.UnloadFramebuffer(t.id)
	if (t.depth.id > 0) do raylib.UnloadTexture(t.depth)
	return t.texture
}

stackTextures :: proc(layers: ..string) -> raylib.Texture {
	defer free_all(context.temp_allocator)

	texs := make([]raylib.Texture, len(layers), context.temp_allocator)
	for l, i in layers do texs[i] = raylib.LoadTexture(strings.clone_to_cstring(l, context.temp_allocator))
	defer for t in texs do raylib.UnloadTexture(t)

	dims := [2]i32{texs[0].width, texs[0].height}
	target := raylib.LoadRenderTexture(dims.x, dims.y)

	raylib.BeginTextureMode(target)
	raylib.ClearBackground({})
	for tex in texs {
		raylib.DrawTextureRec(tex, {0, 0, f32(dims.x), f32(-dims.y)}, {0, 0}, raylib.WHITE)
	}
	raylib.EndTextureMode()

	return gutRenderTexture(target)
}

makePlayer :: proc() -> Character {
	tex := stackTextures(
		"assets/gh_chars/Character skin colors/Female Skin1.png",
		"assets/gh_chars/Female Clothing/Corset.png",
		"assets/gh_chars/Female Clothing/Boots.png",
		"assets/gh_chars/Female Clothing/Socks.png",
		"assets/gh_chars/Female Clothing/Skirt.png",
		"assets/gh_chars/Female Hair/Female Hair3.png",
		"assets/gh_chars/Female Hand/Female Sword.png",
	)

	return {
		{0, 0},
		tex,
		.LEFT,
		.IDLE,
		{.IDLE = {0, {80, 64}, 5}, .WALKING = {64, {80, 64}, 8}},
		0,
		6,
	}
}

updatePlayer :: proc(p: ^Character) {
	p.frame_idx += 1

	moved := false
	if raylib.IsKeyDown(.LEFT) {
		p.pos.x -= 2
		p.facing = .LEFT
		moved = true
	} else if raylib.IsKeyDown(.RIGHT) {
		p.pos.x += 2
		p.facing = .RIGHT
		moved = true
	}

	if moved {
		p.state = .WALKING
	} else {
		p.state = .IDLE
	}

	// if raylib.IsKeyDown(.UP) {
	// 	cam.origin.y -= 5
	// } else if raylib.IsKeyDown(.DOWN) {
	// 	cam.origin.y += 5
	// }


}
