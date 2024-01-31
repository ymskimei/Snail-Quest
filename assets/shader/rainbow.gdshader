
shader_type canvas_item;

uniform float strength: hint_range(0.0, 1.0) = 1.0;
uniform float speed: hint_range(0.0, 10.0) = 0.5;
uniform float angle: hint_range(0.0, 360.0) = 0.0;

void fragment() {
	float hue = UV.x * cos(radians(angle)) - UV.y * sin(radians(angle));
	hue = fract(hue + fract(TIME  * speed));
	float x = 1. - abs(mod(hue / (1.0/ 6.0), 2.0) - 1.0);
	vec3 rainbow;
	if(hue < 1.0 / 6.0){
		rainbow = vec3(1.0, x, 0.0);
	} else if (hue < 1.0 / 3.0) {
		rainbow = vec3(x, 1.0, 0);
	} else if (hue < 0.5) {
		rainbow = vec3(0, 1.0, x);
	} else if (hue < 2./3.0) {
		rainbow = vec3(0.0, x, 1.0);
	} else if (hue < 5.0 / 6.0) {
		rainbow = vec3(x, 0.0, 1.);
	} else {
		rainbow = vec3(1.0, 0.0, x);
	}
	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, vec4(rainbow, color.a), strength);
}


