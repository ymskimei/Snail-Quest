shader_type spatial;
render_mode cull_disabled;

uniform vec4 albedo : hint_color = vec4(1.0);
uniform sampler2D texture_albedo : hint_albedo;

uniform sampler2D diffuse_curve : hint_white;

uniform float specular : hint_range(0,1) = 0.5;
uniform float specular_amount : hint_range(0,1) = 0.5;
uniform float specular_smoothness : hint_range(0,1) = 0.05;
uniform sampler2D texture_specular : hint_white;

uniform float rim : hint_range(0,1) = 0.5;
uniform float rim_amount : hint_range(0,1) = 0.2;
uniform float rim_smoothness : hint_range(0,1) = 0.05;
uniform sampler2D texture_rim : hint_white;

uniform float metallic : hint_range(0,1) = 0.0;
uniform float roughness : hint_range(0,1) = 1.0;
uniform sampler2D texture_surface : hint_white;

uniform vec4 emission : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_energy = 1.0;
uniform sampler2D texture_emission : hint_black_albedo;

uniform vec2 uv_scale = vec2(1,1);
uniform vec2 uv_offset = vec2(0,0);

void vertex() {
	UV = UV * uv_scale.xy + uv_offset.xy;
}

void fragment() {
	ALBEDO = albedo.rgb * texture(texture_albedo, UV).rgb;
	ROUGHNESS = roughness * texture(texture_surface, UV).r;
	METALLIC = metallic * texture(texture_surface, UV).g;
	EMISSION = (emission.rgb + texture(texture_emission, UV).rgb) * emission_energy;
}

const float PI = 3.14159265358979323846;

void light() {
	float spec_value = specular * texture(texture_specular, UV).r;
	float spec_gloss = pow(2.0, 8.0 * (1.0 - specular_amount * texture(texture_specular, UV).g));
	float spec_smooth = specular_smoothness * texture(texture_specular, UV).b;
	float rim_value = rim * texture(texture_rim, UV).r;
	float rim_width = rim_amount * texture(texture_rim, UV).g;
	float rim_smooth = rim_smoothness * texture(texture_rim, UV).b;

	vec3 litness = texture(diffuse_curve, vec2(dot(LIGHT, NORMAL), 0.0)).r * ATTENUATION;
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * litness;

	vec3 half = normalize(VIEW + LIGHT);
	float spec_intensity = pow(dot(NORMAL, half), spec_gloss * spec_gloss);
	spec_intensity = smoothstep(0.05, 0.05 + spec_smooth, spec_intensity);
	SPECULAR_LIGHT += LIGHT_COLOR * spec_value * spec_intensity * litness;

	float rim_dot = 1.0 - dot(NORMAL, VIEW);
	float rim_threshold = pow((1.0 - rim_width), dot(LIGHT, NORMAL));
	float rim_intensity = smoothstep(rim_threshold - rim_smooth/2.0, rim_threshold + rim_smooth/2.0, rim_dot);
	SPECULAR_LIGHT += LIGHT_COLOR * rim_value * rim_intensity * litness;
}