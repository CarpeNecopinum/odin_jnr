package main

import "core:fmt"
import "core:math"
import "core:strings"
import "vendor:box2d"
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
		0.0,
		tex,
		.LEFT,
		.IDLE,
		{.IDLE = {0, {80, 64}, 5}, .WALKING = {64, {80, 64}, 8}},
		0,
		6,
	}
}


applyInputForces :: proc(pb: box2d.BodyId) {
	force := [2]f32{}

	mass := box2d.Body_GetMass(pb)
	if raylib.IsKeyDown(.LEFT) {
		force.x = -200 * mass
	} else if raylib.IsKeyDown(.RIGHT) {
		force.x = 200 * mass
	}

	vel := box2d.Body_GetLinearVelocity(pb)
	if raylib.IsKeyDown(.UP) && math.abs(vel.y) < 10 {
		fmt.println("Jumped")
		box2d.Body_ApplyLinearImpulseToCenter(pb, {0.0, -200.0 * mass}, true)
	}

	box2d.Body_ApplyForceToCenter(pb, force, true)

	torque_factor := 9000 * mass
	rot := box2d.Body_GetRotation(pb)
	box2d.Body_ApplyTorque(pb, -torque_factor * box2d.Rot_GetAngle(rot), true)
}
updatePlayer :: proc(p: ^Character, pb: box2d.BodyId) {
	p.frame_idx += 1

	frame_size := p.animations[.IDLE].frame_size
	p.pos = ([2]i32)(box2d.Body_GetPosition(pb)) - frame_size / 2
	rot := box2d.Body_GetRotation(pb)
	p.rot = math.atan2(rot.s, rot.c)

	vel := box2d.Body_GetLinearVelocity(pb)
	if vel.x > 10 {
		p.facing = .RIGHT
		p.state = .WALKING
	} else if vel.x < -10 {
		p.facing = .LEFT
		p.state = .WALKING
	} else {
		p.state = .IDLE
	}
}


makePlayerBody :: proc(w: box2d.WorldId, p: Character) -> box2d.BodyId {
	frame_size := p.animations[.IDLE].frame_size
	bodyDef := box2d.DefaultBodyDef()
	bodyDef.type = .dynamicBody
	bodyDef.position.x = f32(p.pos.x + frame_size.x / 2)
	bodyDef.position.y = f32(p.pos.y + frame_size.y / 3)
	bodyId := box2d.CreateBody(w, bodyDef)

	box := box2d.MakeOffsetBox(
		f32(frame_size.x / 8),
		f32(frame_size.y / 3),
		([2]f32){0, f32(frame_size.y / 6)},
		box2d.Rot_identity,
	)
	shapeDef := box2d.DefaultShapeDef()
	shapeDef.material.friction = 0.1
	_ = box2d.CreatePolygonShape(bodyId, shapeDef, box)

	return bodyId
}
