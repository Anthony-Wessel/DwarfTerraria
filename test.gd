extends TextureRect

@export var vport : SubViewport

func _process(delta):
	texture = vport.get_texture()
