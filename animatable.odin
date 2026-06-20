package main

import "core:math"
import "vendor:raylib"

Facing :: enum {
	LEFT  = 0,
	RIGHT = 1,
}
Animation :: struct {
	y:          i32,
	frame_size: [2]i32,
	num_frames: i32,
}
Animatable :: struct($StateEnum: typeid) {
	pos:           [2]i32,
	rot:           f32,
	texture:       raylib.Texture,
	facing:        Facing,
	state:         StateEnum,
	animations:    [CharacterState]Animation,
	frame_idx:     i32,
	frame_divisor: i32,
}

drawAnimatable :: proc($T: typeid, p: Animatable(T), gs: GameState) {
	make_rect :: proc(pos: [2]i32, size: [2]i32) -> raylib.Rectangle {
		return {f32(pos.x), f32(pos.y), f32(size.x), f32(size.y)}
	}

	anim := p.animations[p.state]
	frame_idx := (p.frame_idx / p.frame_divisor) % anim.num_frames
	src_pos := [2]i32{frame_idx * anim.frame_size.x, anim.y}
	src := make_rect(src_pos, anim.frame_size)
	dst := make_rect(
		anim.frame_size / 2 - p.pos,
		//p.pos,
		anim.frame_size,
		// (p.pos + anim.frame_size / 2) * gs.camera.scale - gs.camera.origin,
		// anim.frame_size * gs.camera.scale,
	)
	if p.facing == .RIGHT {
		src.width = -src.width
	}

	raylib.DrawTexturePro(
		p.texture,
		src,
		dst,
		{},
		// ([2]f32)(p.pos),
		// ([2]f32)(anim.frame_size / 2 * gs.camera.scale),
		math.to_degrees(p.rot),
		raylib.Color{255, 255, 255, 255},
	)
}
