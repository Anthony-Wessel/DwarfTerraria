extends Node

var rd : RenderingDevice

func _ready():
	rd = RenderingServer.create_local_rendering_device()

# Assumes output is a single image
# Assumes input is a list of textures
func run_shader(shader_path : String, input, output_width, output_height) -> Texture2D:
	var shader_file := load(shader_path)
	var shader_spirv : RDShaderSPIRV = shader_file.get_spirv()
	var shader : RID = rd.shader_create_from_spirv(shader_spirv)
	var view := RDTextureView.new()
	var uniform_list = []
	
	# setup output image
	var output_fmt = create_image_format(output_width, output_height)
	var output_image := Image.create(output_width,output_height,false,Image.FORMAT_RGBAF)
	var output_tex = rd.texture_create(output_fmt, view, [output_image.get_data()])
	var output_tex_uniform := RDUniform.new()
	output_tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	output_tex_uniform.binding = 0
	output_tex_uniform.add_id(output_tex)
	uniform_list.append(output_tex_uniform)
	
	# setup input textures
	var binding = 1
	for tex in input:
		var sampler_state := RDSamplerState.new()
		var sampler = rd.sampler_create(sampler_state)
		
		var fmt = create_sampler_format(tex.get_width(), tex.get_height())
		
		var img = tex.get_image()
		img.convert(Image.FORMAT_RGBAF)
		var rd_tex = rd.texture_create(fmt, view, [img.get_data()])
		var uniform := RDUniform.new()
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
		uniform.binding = binding
		binding += 1
		uniform.add_id(sampler)
		uniform.add_id(rd_tex)
		
		uniform_list.append(uniform)
	
	# 
	var uniform_set := rd.uniform_set_create(uniform_list, shader, 0)
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, output_width, output_height, 1)
	rd.compute_list_end()
	
	rd.submit()
	rd.sync()
	
	var output_bytes := rd.texture_get_data(output_tex,0)
	output_image.set_data(output_width,output_height,false,Image.FORMAT_RGBAF, output_bytes)
	
	return ImageTexture.create_from_image(output_image)

func create_image_format(width, height):
	var fmt := RDTextureFormat.new()
	fmt.width = width
	fmt.height = height
	fmt.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	return fmt
	
func create_sampler_format(width, height):
	var fmt_input = RDTextureFormat.new()
	fmt_input.width = width
	fmt_input.height = height
	fmt_input.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	fmt_input.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	
	return fmt_input
