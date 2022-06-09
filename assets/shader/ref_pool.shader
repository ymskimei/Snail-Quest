// A modified pool shader to deal with reflections made with a
// camera node in a viewport.
shader_type spatial;
render_mode depth_draw_always;



uniform vec4 water_color : hint_color = vec4(1.0);
uniform vec4 foam_color : hint_color = vec4(0.5);
uniform float reflectiveness: hint_range(0,1) = 0.8;
uniform float agitation: hint_range(0,1) = 0.0;
uniform float specularity = 1.0;
uniform float foam_brightness = 1.0;
uniform bool fresnel_effect = false;
uniform bool fixed_foam_brightness = false;
uniform bool depth_based_foam = false;
uniform bool depth_transparency = true;

uniform float foam_smoothness: hint_range(0,1) = 0.1;
uniform float foam_size: hint_range(0,1) = 0.4;
uniform float foam_displacement: hint_range(0,1) = 0.6;

uniform vec2 ripples_speed_1 = vec2(1,0);
uniform vec2 ripples_speed_2 = vec2(0,1);

uniform vec2 uv_scale = vec2(1,1);
uniform vec2 uv_offset = vec2(0,0);

uniform sampler2D foam_map : hint_black;
uniform sampler2D foam_noise : hint_white;
uniform sampler2D normalmap_texture : hint_normal;
uniform sampler2D reflections : hint_black;

const float PI = 3.14159265358979323846;



void vertex() {
	UV = UV * uv_scale.xy + uv_offset.xy;
}



// This function turns distances from depth texture into linear system.
float linearize(float depth, mat4 inv_proj, vec2 screen_uv) {
	vec4 view_pos = inv_proj * vec4(vec3(screen_uv, depth) * 2.0 - 1.0, 1.0);
	return -view_pos.z / view_pos.w;
}

// Old linearize function. Neads near and far values from the camera it's rendering from.
//
//float linearize(float depth) {
//	depth = 2.0 * depth - 1.0;
//	return 2.0 * near * far / (near + far + depth * (near - far));
//}


void fragment() {
	// Edge foam code. We set TRANSMISSION.x to 1 if the pixel has foam and to 0 otherwise
	// (and anything in between is smoothing). We use the TRANSMISSION property because it can be
	// read by the light pass. It's our way of cheating the limitation of not being able to send
	// information from fragment to light. For this to work properly, we need to write something
	// to DIFFUSE_LIGHT, or else writing to this property will change the final look. This first
	// part is about the foam map part. To turn it off, just leave the foam map uniform empty.
	float base = texture(foam_map, (UV - uv_offset) / uv_scale).x;
	float displ = (2.0 * texture(foam_noise, UV - TIME * (0.2 + agitation * 3.0) / 16.0).x - 1.0) * foam_displacement;
	float foam = (1.0 - foam_size) + displ * (base == 0.0 ? 0.0 : 1.0);
	TRANSMISSION.x += smoothstep(foam, foam + foam_smoothness, base);
	
	// This part deals with the depth calculated foam. 
	float zdepth = linearize(texture(DEPTH_TEXTURE, SCREEN_UV).x, INV_PROJECTION_MATRIX, SCREEN_UV);
	float zpos = linearize(FRAGCOORD.z, INV_PROJECTION_MATRIX, SCREEN_UV);
	float diff = zdepth - zpos;
	float t = diff < 0.0 ? 1.0 : (diff + displ) * 8.0; // Deals with the contour on things in front of the water.
	TRANSMISSION.x += depth_based_foam ? 1.0 - smoothstep(foam_size, foam_size + foam_smoothness, t) : 0.0;
	
	// Final foam bits.
	TRANSMISSION.x = clamp(TRANSMISSION.x, 0.0, 1.0);
	float foam_strength = fixed_foam_brightness ? foam_brightness : clamp(agitation * 2.0, 0.0, 1.0) * foam_brightness;
	
	// We'll make the ripples by changing the normal map, since these waves are more detailed
	// and don't need to visibly go up and down other meshes. We also made the last two line variables
	// because we'll use them to deform refractions and reflections.
	vec3 agi_1 = texture(normalmap_texture, UV + ripples_speed_1 * TIME * (agitation + 0.1) * 0.25).rgb;
	vec3 agi_2 = texture(normalmap_texture, UV + ripples_speed_2 * TIME * (agitation + 0.1) * 0.25).rgb;
	NORMALMAP = mix(agi_1, agi_2, 0.5);
	NORMALMAP_DEPTH = clamp(agitation * 3.0 + 0.2, 0.0, 2.0);
	vec3 nmap = 2.0 * NORMALMAP - 1.0;
	vec3 normal = normalize(mix(NORMAL, TANGENT*nmap.x + BINORMAL*nmap.y + NORMAL*nmap.z, NORMALMAP_DEPTH));
	float diff_ang = acos(dot(NORMAL, normal));
	vec2 diff_dir = normalize(2.0 * NORMALMAP.xy - 1.0);
	
	// Reflections done with a second camera. We have to position it as if it was opposite to
	// the active camera in relation to the water pool, as if it is the reflected camera.
	// Since we'll be rendering the screen again to make it work, this method of getting
	// reflections is expensive although it makes really good reflections. You can decrease
	// the reflection's quality to make it lighter on the GPU in expense of visual fidelity.
	// Beware billboards shaders (like the flames), the camera frustum isn't always pointing
	// at the camera's looking direction. Lastly, I want to talk about the Fresnel effect.
	// Using Schlick's approximation, the actual reflectance should be equal to
	// reflectiveness + (1.0 - reflectiveness) * pow(1.0 - dot(normal, -VIEW), 5.0).
	// However, as it doesn't look good on a cartoony look. You can use it if you want a
	// more realistic looking water, or you can mess around to see what you like best (for
	// reference, water's realistic reflectiveness value would be around 0.0204).
	// For a toonified look, this is what I chose:
	float fresnel = reflectiveness + (1.0 - reflectiveness) * smoothstep(0.45, 0.55, 1.0 - dot(normal, -VIEW));
	fresnel = fresnel_effect ? fresnel : reflectiveness;
	vec2 refl_uv = (UV - uv_offset) / uv_scale - diff_dir * diff_ang * 0.004 / zpos;
	vec3 reflection = texture(reflections, refl_uv).rgb / 7.5;
	
	// Refraction from Godot's base code, a little bit modified to look better and
	// to eliminate some problems it has with moving water and stuff above it. This code
	// has a problem: SCREEN_TEXTURE doesn't get transparent things, so any transparent
	// object or things that use the SCREEN_TEXTURE in its shader material code won't show
	// up underwater. The easiest solution I can think of is to forget the refraction effect
	// and just use the alpha channel. Other than that, another solution I can think of is
	// to setup a another camera that's always looking at where the active camera is looking
	// and it can't see the water. You render that camera's vision into a Viewport, send it
	// to this shader in the form of a sampler2D uniform and trade SCREEN_TEXTURE for that
	// uniform. This way, you will be rendering the whole screen without the water once on
	// this camera, and then you send this information to this shader here, which will capture
	// all transparency and crazy shaders with SCREEN_TEXTURE underwater. The price you pay
	// is performance, since you will be rendering the screen twice, obviously. Oh, and it
	// won't show up on the editor, but that's not really a problem.
	vec2 ref_ofs = SCREEN_UV - diff_dir * diff_ang * 0.004 / zpos;
	ref_ofs = zpos < linearize(texture(DEPTH_TEXTURE, ref_ofs).x, INV_PROJECTION_MATRIX, SCREEN_UV) ? ref_ofs : SCREEN_UV;
	float ref_diff = linearize(texture(DEPTH_TEXTURE, ref_ofs).x, INV_PROJECTION_MATRIX, SCREEN_UV) - zpos;
	float alpha = depth_transparency ? clamp(ref_diff * tan(water_color.a * PI / 2.0), 0.0, 1.0) : water_color.a;
	vec3 refraction = texture(SCREEN_TEXTURE, ref_ofs).rgb * (1.0 - alpha);
	
	// Final information to output. We use EMISSION for refractions and reflections becase it
	// doesn't get lit up on the light pass. We also multiply it by 1.0 - TRANSMISSION.x * foam_strenth
	// in order to turn off both on the foam. I don't think foam should be reflective or transparent.
	EMISSION = mix(refraction, reflection, fresnel) * clamp(1.0 - TRANSMISSION.x * foam_strength, 0.0, 1.0);
	ALBEDO = mix(water_color.rgb * alpha * (1.0 - fresnel), foam_color.rgb, TRANSMISSION.x * foam_strength);
}



// Lighting uniforms from base toon code turned into constants.
// We only need specular here.
const float specular_glossiness = 16.0;
const float specular_smoothness = 0.04;

void light() {
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION; // No shading, fresh water is fully transmissive.
	
	// We multiply SPECULAR_LIGHT by 1.0 - TRANSMISSION.x to turn off specular on the foam.
	// We have to send this information through TRANSMISSION.x because we can't access
	// SCREEN_TEXTURE here in order to calculate foam. Even if we could, this way is cheaper.
	vec3 half = normalize(VIEW + LIGHT);
	float spec_intensity = pow(dot(NORMAL, half), specular_glossiness * specular_glossiness);
	spec_intensity = smoothstep(0.05, 0.05 + specular_smoothness, spec_intensity) * clamp(agitation * 2.0, 0.0, 1.0);
	SPECULAR_LIGHT += LIGHT_COLOR * spec_intensity * specularity * ATTENUATION * (1.0 - TRANSMISSION.x);
}


