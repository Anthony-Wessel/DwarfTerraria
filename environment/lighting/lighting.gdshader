shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 screen_resolution;
uniform float radius;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
	vec2 pixel_size = vec2(1.0/screen_resolution.x, 1.0/screen_resolution.y);
	for (float x = -radius; x <= radius; x += 1.0)
	{
		for (float y = -radius; y <= radius; y += 1.0)
		{
			vec2 uv = UV + vec2(pixel_size.x * x, pixel_size.y * y);
			color += texture(TEXTURE, uv);
		}
	}
	color *= (1.0/pow(2.0*radius+1.0, 2));
	color.a = 1.0;

	COLOR = texture(screen_texture, SCREEN_UV) * color;
}
