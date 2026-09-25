shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

uniform sampler2D fog_tex : filter_nearest, repeat_disable;
// R: 0 unexplored, ~0.5 explored, 1 visible
uniform float unexplored_alpha : hint_range(0.0, 1.0) = 0.92;
uniform float explored_alpha : hint_range(0.0, 1.0) = 0.50;
uniform vec3 fog_color = vec3(0.02, 0.03, 0.05);

void fragment() {
	// PlaneMesh UV: 0..1 across map
	float v = texture(fog_tex, UV).r;
	float a = unexplored_alpha;
	if (v > 0.75) {
		a = 0.0;
	} else if (v > 0.25) {
		a = explored_alpha;
	}
	ALBEDO = fog_color;
	ALPHA = a;
}
