package main

import "vendor:raylib"


makePlayer :: proc() -> Character {
	return {
		{0, 0},
		raylib.LoadTexture("assets/gh_chars/Character skin colors/Female Skin1.png"),
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
