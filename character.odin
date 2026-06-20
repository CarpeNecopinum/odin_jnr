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

focusCharacter :: proc(c: ^raylib.Camera2D, p: Character) {
	new_target := p.pos + p.animations[.IDLE].frame_size
	c.target = 0.9 * c.target + 0.1 * ([2]f32)(new_target)
}

moveCharacterToObject :: proc(p: ^Character, o: MapObject) {
	p.pos.x = o.x - p.animations[.IDLE].frame_size.x / 2
	p.pos.y = o.y - p.animations[.IDLE].frame_size.y
}
