shader_type spatial;
render_mode async_visible, blend_mix, depth_draw_alpha_prepass, cull_disabled;

uniform bool use_diffuse = false;
uniform bool use_specular = false;
uniform bool use_rim = false;
uniform bool use_light = false;
uniform bool use_shadow = false;

uniform vec4 albedo_color: hint_color = vec4(1.0);
uniform vec4 shade_color: hint_color = vec4(1.0);
uniform vec4 specular_color: hint_color = vec4(0.75);
uniform vec4 rim_color: hint_color = vec4(0.75);
uniform vec4 emission: hint_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float normal_scale: hint_range(-16, 16) = 0.1;
uniform float shade_threshold : hint_range(-1.0, 1.0) = 0.0;
uniform float shade_softness : hint_range(0.0, 1.0) = 0.05;
uniform float specular_glossiness : hint_range(1.0, 100.0) = 15.0;
uniform float specular_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float specular_softness : hint_range(0.0, 1.0) = 0.0;
uniform float rim_threshold : hint_range(0.0, 1.0) = 0.25;
uniform float rim_softness : hint_range(0.0, 1.0) = 0.0;
uniform float rim_spread : hint_range(0.0, 1.0) = 0.5;
uniform float shadow_threshold : hint_range(0.0, 1.0) = 0.7;
uniform float shadow_softness : hint_range(0.0, 1.0) = 0.05;
uniform float emission_energy = 0.0;

uniform sampler2D texture_albedo: hint_albedo;
uniform sampler2D texture_normal : hint_normal;
uniform sampler2D texture_emission : hint_black_albedo;
uniform sampler2D texture_screen;
uniform float screen_scale = 10.0;

uniform vec3 uv_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv_offset = vec3(1.0, 0.0, 0.0);

uniform bool use_triplanar = false;

varying vec3 uv_power_normal;
varying vec3 uv_triplanar_pos;

void vertex() {
	TANGENT = vec3(0.0, 0.0, -1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0, 0.0, 0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0, 0.0, 0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0, 1.0, 0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0, 0.0, -1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0, 1.0, 0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	uv_power_normal = abs(NORMAL);
	uv_power_normal /= dot(uv_power_normal, vec3(1.0));
	uv_triplanar_pos = VERTEX * uv_scale + uv_offset;
	uv_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler, vec2 uv) {
	vec4 samp = vec4(0.0);
    if (use_triplanar) {
	samp += texture(p_sampler, uv_triplanar_pos.xy) * uv_power_normal.z;
	samp += texture(p_sampler, uv_triplanar_pos.xz) * uv_power_normal.y;
	samp += texture(p_sampler, uv_triplanar_pos.zy * vec2(-1.0, 1.0)) * uv_power_normal.x;
	} else {
		samp = texture(p_sampler, uv);
	}
	return samp;
}

void fragment() {
	ALBEDO = albedo_color.rgb * triplanar_texture(texture_albedo, UV).rgb;
	NORMALMAP = triplanar_texture(texture_normal, UV).rgb;
	EMISSION = (emission.rgb + triplanar_texture(texture_emission, UV).rgb) * emission_energy;
	ALPHA = albedo_color.a * triplanar_texture(texture_albedo, UV).a;  
	NORMALMAP_DEPTH = normal_scale;
}

void light() {
	vec2 uv = FRAGCOORD.xy;
	vec2 tiling_uv = uv / (10.0 * screen_scale * -1.0);
	vec4 texture_result = texture(texture_screen, tiling_uv);
	float NdotL = dot(NORMAL, LIGHT);
	float is_lit = step(shade_threshold, NdotL);
	vec4 base = triplanar_texture(texture_albedo, UV).rgba * albedo_color.rgba * texture_result.rgba;
	vec4 shade = triplanar_texture(texture_albedo, UV).rgba * shade_color.rgba * texture_result.rgba;
	vec4 diffuse = base;
	if (use_diffuse) {
		float shade_value = smoothstep(shade_threshold - shade_softness , shade_threshold + shade_softness, NdotL);
		diffuse = mix(shade, base, shade_value);
		if (use_shadow) {
			float shadow_value = smoothstep(shadow_threshold - shadow_softness ,shadow_threshold + shadow_softness, ATTENUATION.r);
			shade_value = min(shade_value, shadow_value);
			diffuse = mix(shade, base, shade_value);
			is_lit = step(shadow_threshold, shade_value);
		}
	}
	if (use_specular) {
		vec3 half = normalize(VIEW + LIGHT);
		float NdotH = dot(NORMAL, half);
		float specular_value = pow(NdotH * is_lit, specular_glossiness * specular_glossiness);
		specular_value = smoothstep(specular_threshold - specular_softness, specular_threshold + specular_softness, specular_value);
		vec4 specular_contribution = specular_color.rgba * specular_value * is_lit * 1.0;
		diffuse = mix(diffuse, specular_contribution, specular_value);
	}
	if (use_rim) {
		float iVdotN = 1.0 - dot(VIEW, NORMAL);
		float inverted_rim_threshold = 1.0 - rim_threshold;
		float inverted_rim_spread = 1.0 - rim_spread;
		float rim_value = iVdotN * pow(NdotL, inverted_rim_spread);
		rim_value = smoothstep(inverted_rim_threshold - rim_softness, inverted_rim_threshold + rim_softness, rim_value);
		vec4 rim_contribution = rim_color.rgba * rim_value * is_lit * 1.0;
		diffuse = mix(diffuse, rim_contribution, rim_value);
	}
	if (use_light) {
		diffuse *= vec4(LIGHT_COLOR, 1.0);
	}
	DIFFUSE_LIGHT = diffuse.rgb;
	ALPHA = diffuse.a;
}