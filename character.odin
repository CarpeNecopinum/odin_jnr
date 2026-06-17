package main

import "vendor:raylib"

CharacterState :: enum {
	IDLE,
	WALKING,
	// RUNNING,
	// FLYING,
	// JUMPING,
	// HITTING,
	// DYING,
}

Character :: Animatable(CharacterState)

drawCharacter :: proc(p: Character, gs: GameState) {
	drawAnimatable(CharacterState, p, gs)
}

focusCharacter :: proc(c: ^Camera, p: Character) {
	ff :: [2]f32
	ii :: [2]i32

	goal := (p.pos * c.scale) - c.size / 2 + p.animations[.IDLE].frame_size * c.scale / 2
	c.origin = ii(0.9 * ff(c.origin) + 0.1 * ff(goal))
}
