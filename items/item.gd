class_name Item
extends Resource

@export var name : String
@export var texture : Texture

func get_use_scene():
	push_error("No use scene is set")
