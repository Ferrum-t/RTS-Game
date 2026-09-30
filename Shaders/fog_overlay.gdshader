shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

// M24 — soft edges + near-black FoW (VisibilityMap data unchanged).
uniform sampler2D fog_tex : filter_linear, repeat_disable;
// R: 0 unexplored, ~0.5 explored, 1 visible
uniform float unexplored_alpha : hint_range(0.0, 1.0) = 0.96;
uniform float explored_alpha : hint_range(0.0, 1.0) = 0.60;
uniform vec3 fog_color = vec3(0.0, 0.0, 0.0);

void fragment() {
	float v = texture(fog_tex, UV).r;
	// Soft blend between states (linear sample already softens cell edges).
	float w_unexplored = 1.0 - smoothstep(0.0, 0.40, v);
	float w_explored = smoothstep(0.05, 0.40, v) * (1.0 - smoothstep(0.55, 0.95, v));
	float a = w_unexplored * unexplored_alpha + w_explored * explored_alpha;
	ALBEDO = fog_color;
	ALPHA = clamp(a, 0.0, 1.0);
}
