shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float dist = 0.05;

void fragment() {
	vec4 color1 = texture(TEXTURE, UV+vec2(dist,0));
	vec4 color2 = texture(TEXTURE, UV+vec2(-dist,0));
	vec4 color3 = texture(TEXTURE, UV+vec2(0,dist));
	vec4 color4 = texture(TEXTURE, UV+vec2(0,-dist));
	vec4 color_center = texture(TEXTURE, UV);
	
	vec4 color = (color1+color2+color3+color4+color_center)*0.2;
	COLOR = textureLod(screen_texture, SCREEN_UV, 0.0) * color;
}
