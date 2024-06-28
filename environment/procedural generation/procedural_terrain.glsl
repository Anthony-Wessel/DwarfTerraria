#[compute]
#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, r8) uniform image2D OUTPUT_TEXTURE;
layout(set = 0, binding = 1) uniform sampler2D BASE_TEXTURE;

void main()
{
  ivec2 texel = ivec2(gl_GlobalInvocationID.xy);
  vec2 uv = (vec2(0.5,0.5)+texel) * 1.0/textureSize(BASE_TEXTURE,0);
  vec4 color = texture(BASE_TEXTURE, uv);
  vec4 end_color = vec4(0.0, 0.0, 0.0, 1.0);

  if (color.r > 0.5)
  {
	end_color = vec4(1.0, 1.0, 1.0, 1.0);
  }
  
  imageStore(OUTPUT_TEXTURE, texel, end_color);
}
