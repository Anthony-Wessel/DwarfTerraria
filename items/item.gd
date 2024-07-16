class_name Item
extends Resource

@export var name : String
@export var texture : Texture
@export var held_texture : Texture
@export var use_scene : PackedScene : get = get_use_scene

func get_use_scene():
	return use_scene
