#[compute]
#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba32f) uniform image2D OUTPUT_TEXTURE;
layout(set = 0, binding = 1) uniform sampler2D CAVE_TEXTURE;
layout(set = 0, binding = 2) uniform sampler2D ORE_TEXTURE;

float rand1dTo1d(float value, float mutator)
{
	return fract(sin(value+mutator)*143758.5453);
}

void main()
{
	ivec2 texel = ivec2(gl_GlobalInvocationID.xy);
	vec2 uv = texel/99.0;


	float value = texture(ORE_TEXTURE, uv).r;
	value = rand1dTo1d(value, 3.9812);
	value = value * 5.0 - 4.0;
	vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
	if (value > 0)
	{
		if (value < 0.1)
			color = vec4(1.0, 0.0, 0.0, 1.0);
		else if (value < 0.2)
			color = vec4(0.0, 1.0, 0.0, 1.0);
		else if (value < 0.3)
			color = vec4(0.0, 0.0, 1.0, 1.0);
	}
	imageStore(OUTPUT_TEXTURE, texel, texture(CAVE_TEXTURE, uv) * color);
}
