shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_alpha_prepass;

uniform sampler2D texture_albedo;
uniform vec3 light_direction = vec3(0.5, 0.5, 0.5);

uniform vec4 albedo_color: hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 shadow_color: hint_color = vec4(0.5, 0.5, 0.5, 1.0);

uniform float shadow_threshold: hint_range(0.0, 1.0) = 0.05;

uniform bool use_triplanar = false;
uniform vec3 uv_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv_offset = vec3(0.0, 0.0, 0.0);

varying vec3 world_position;
varying vec3 uv_triplanar_pos;
varying vec3 uv_power_normal;
varying vec3 world_normal;

uniform mat4 shadow_view_projection_matrix;
uniform sampler2D shadow_map;  // The shadow map texture

varying vec4 shadow_pos;

void vertex() {
    world_normal = normalize((WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz);

    uv_triplanar_pos = VERTEX * uv_scale + uv_offset;
    uv_triplanar_pos *= vec3(1.0, -1.0, 1.0);
    uv_power_normal = abs(NORMAL);
    uv_power_normal /= dot(uv_power_normal, vec3(1.0));
}

vec4 triplanar_texture(sampler2D sampler, vec2 uv) {
    vec4 samp = vec4(0.0);
    if (use_triplanar) {
        samp += texture(sampler, uv_triplanar_pos.xy) * uv_power_normal.z;
        samp += texture(sampler, uv_triplanar_pos.xz) * uv_power_normal.y;
        samp += texture(sampler, uv_triplanar_pos.zy * vec2(-1.0, 1.0)) * uv_power_normal.x;
    } else {
        samp = texture(sampler, uv);
    }
    return samp;
}

void fragment() {
    vec4 texture_color = triplanar_texture(texture_albedo, UV);
    vec3 base_color = albedo_color.rgb * texture_color.rgb;

    float NdotL = dot(world_normal, light_direction);
    NdotL = smoothstep(0.0, shadow_threshold, NdotL);

    vec3 diffuse = base_color * texture_color.rgb;
    vec3 shadow_effect = mix(vec3(1.0), shadow_color.rgb, 1.0 - NdotL);

    ALBEDO = diffuse * shadow_effect;
    ALPHA = texture_color.a;
}