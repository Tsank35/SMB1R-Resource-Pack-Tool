shader_type canvas_item;

uniform vec3 color1: source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 color2: source_color = vec3(0.5, 0.5, 0.5);
uniform vec3 color3: source_color = vec3(0.0, 0.0, 0.0);

const float HALF = 128.0 / 255.0;
const vec3 COLOR1 = vec3(1.0, 1.0, 1.0);
const vec3 COLOR2 = vec3(HALF, HALF, HALF);
const vec3 COLOR3 = vec3(0.0, 0.0, 0.0);

void fragment() {
	vec3 pixel = texture(TEXTURE, UV).rgb;
	if (pixel == COLOR1) {pixel = color1;}
	else if (pixel == COLOR2) {pixel = color2;}
	else if (pixel == COLOR3) {pixel = color3;}
	COLOR.rgb = pixel;
}
