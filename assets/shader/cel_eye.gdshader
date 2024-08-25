shader_type spatial;
render_mode cull_disabled, depth_draw_alpha_prepass, unshaded;

uniform sampler2D texture_albedo: hint_albedo;
uniform vec4 albedo_color: hint_color;
uniform vec2 pupil_position = vec2(0.0, 0.0); // Position of the pupil, range [-1, 1]

uniform bool is_right = false;

void fragment() {
	vec2 uv = UV;
	vec2 corrected_pupil_position;

	corrected_pupil_position = pupil_position + vec2(-1.0, 1.0);
	if (is_right) {
		corrected_pupil_position = corrected_pupil_position + vec2(0.0, 2.0);
	}

	uv += corrected_pupil_position * 0.25;
	vec4 pupil = albedo_color * texture(texture_albedo, uv);

	ALBEDO = pupil.rgb;
	ALPHA = pupil.a;
}
