extends TextureRect

@export var vport : SubViewport

func _process(_delta):
	texture = vport.get_texture()
