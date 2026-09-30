shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

// M24 polish — denser WC-like FoW; UV remapped so oversized plane stays aligned.
uniform sampler2D fog_tex : filter_linear, repeat_disable;
uniform float unexplored_alpha : hint_range(0.0, 1.0) = 0.98;
uniform float explored_alpha : hint_range(0.0, 1.0) = 0.78;
uniform vec3 fog_color = vec3(0.0, 0.0, 0.0);
// Playable map half-extent (VisibilityMap ±95).
uniform float map_half : hint_range(1.0, 200.0) = 95.0;
// Fog plane half-extent (map_half + margin).
uniform float plane_half : hint_range(1.0, 250.0) = 119.0;

void fragment() {
	// PlaneMesh UV 0..1 → world XZ on oversized plane → fog UV on ±map_half.
	float world_x = mix(-plane_half, plane_half, UV.x);
	float world_z = mix(-plane_half, plane_half, UV.y);
	float u = (world_x + map_half) / (map_half * 2.0);
	float v = (world_z + map_half) / (map_half * 2.0);

	if (u < 0.0 || u > 1.0 || v < 0.0 || v > 1.0) {
		ALBEDO = fog_color;
		ALPHA = unexplored_alpha;
		return;
	}

	float fog_v = texture(fog_tex, vec2(u, v)).r;
	float a = mix(unexplored_alpha, explored_alpha, smoothstep(0.02, 0.38, fog_v));
	a = mix(a, 0.0, smoothstep(0.58, 0.96, fog_v));
	ALBEDO = fog_color;
	ALPHA = clamp(a, 0.0, 1.0);
}
