shader_type canvas_item;

uniform float daylight = 5.0;

void fragment() {
	float value = max(COLOR.r, max(0.2,daylight-COLOR.g)) / 30.0;

	COLOR = vec4(value, value, value, value);
}
