shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

// M24 polish — WC-like denser FoW (data grid unchanged).
uniform sampler2D fog_tex : filter_linear, repeat_disable;
// R: 0 unexplored, ~0.5 explored, 1 visible
uniform float unexplored_alpha : hint_range(0.0, 1.0) = 0.98;
uniform float explored_alpha : hint_range(0.0, 1.0) = 0.78;
uniform vec3 fog_color = vec3(0.0, 0.0, 0.0);

void fragment() {
	float v = texture(fog_tex, UV).r;
	// Solid black never-seen → dark dim memory → clear only when visible.
	float a = mix(unexplored_alpha, explored_alpha, smoothstep(0.02, 0.38, v));
	a = mix(a, 0.0, smoothstep(0.58, 0.96, v));
	ALBEDO = fog_color;
	ALPHA = clamp(a, 0.0, 1.0);
}
