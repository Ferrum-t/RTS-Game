shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

// M24 — near-black FoW, soft only at VISIBLE edge (less gray blob).
uniform sampler2D fog_tex : filter_linear, repeat_disable;
// R: 0 unexplored, ~0.5 explored, 1 visible
uniform float unexplored_alpha : hint_range(0.0, 1.0) = 0.97;
uniform float explored_alpha : hint_range(0.0, 1.0) = 0.72;
uniform vec3 fog_color = vec3(0.0, 0.0, 0.0);

void fragment() {
	float v = texture(fog_tex, UV).r;
	// UNEXPLORED stays near-opaque black; EXPLORED dark; soft fade only into VISIBLE.
	float a = mix(unexplored_alpha, explored_alpha, smoothstep(0.05, 0.45, v));
	a = mix(a, 0.0, smoothstep(0.55, 0.92, v));
	ALBEDO = fog_color;
	ALPHA = clamp(a, 0.0, 1.0);
}
