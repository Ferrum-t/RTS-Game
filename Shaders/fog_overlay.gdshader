shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

// M24 — Warcraft-ish FoW: solid black unexplored, dark explored, soft visible rim.
uniform sampler2D fog_tex : filter_linear, repeat_disable;
// R: 0 unexplored, ~0.5 explored, 1 visible (hi-res soft)
uniform float unexplored_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float explored_alpha : hint_range(0.0, 1.0) = 0.82;
uniform vec3 fog_color = vec3(0.0, 0.0, 0.0);

void fragment() {
	float v = texture(fog_tex, UV).r;
	// Hard black for never-seen; strong dim for memory; clear only when fully visible.
	float a = mix(unexplored_alpha, explored_alpha, smoothstep(0.02, 0.35, v));
	a = mix(a, 0.0, smoothstep(0.62, 0.98, v));
	ALBEDO = fog_color;
	ALPHA = clamp(a, 0.0, 1.0);
}
