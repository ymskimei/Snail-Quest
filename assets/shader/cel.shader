shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always;

uniform sampler2D texture_albedo;
uniform vec3 light_direction;

uniform vec4 albedo_color: hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 shadow_color: hint_color = vec4(0.5, 0.5, 0.5, 1.0);

uniform float shading_hardness: hint_range(0.0, 1.0) = 0.05;

uniform bool use_triplanar = false;
uniform vec3 uv_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv_offset = vec3(0.0, 0.0, 0.0);

varying vec3 world_position;
varying vec3 uv_triplanar_pos;
varying vec3 uv_power_normal;
varying vec3 world_normal;

void vertex() {
    world_position = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;

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
    vec3 texture_color = triplanar_texture(texture_albedo, UV).rgb;
    vec3 base_color = albedo_color.rgb * texture_color;

    float NdotL = dot(world_normal, light_direction);
    NdotL = smoothstep(0.0, shading_hardness, NdotL);

    vec3 diffuse = base_color * texture_color;
    vec3 shadow_effect = mix(vec3(1.0), shadow_color.rgb, 1.0 - NdotL);

    ALBEDO = diffuse * shadow_effect;
    ALPHA = albedo_color.a;
}