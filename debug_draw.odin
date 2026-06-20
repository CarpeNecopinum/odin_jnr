package main

import "base:runtime"
import "core:fmt"
import "vendor:box2d"
import "vendor:raylib"

makeDebugDraw :: proc(gs: ^GameState) -> box2d.DebugDraw {
	dd := box2d.DefaultDebugDraw()
	dd.DrawSolidPolygonFcn = proc "c" (
		transform: box2d.Transform,
		vertices: [^][2]f32,
		count: i32,
		radius: f32,
		color: box2d.HexColor,
		ctx: rawptr,
	) {
		gs := (^GameState)(ctx)
		c := (raylib.Color)(i32(color) << 2 | 0xff)
		vtcs := [16][2]f32{}
		for i in 0 ..< count {
			vtcs[i] = box2d.TransformPoint(transform, vertices[i])
		}
		vtcs[count] = vtcs[0]
		raylib.DrawLineStrip(&vtcs[0], count + 1, raylib.WHITE)
	}
	dd.drawShapes = true
	dd.userContext = gs

	return dd
}
