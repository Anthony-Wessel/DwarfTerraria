class_name TileItem
extends Item


@export var tile_id : int

func get_use_scene():
	return preload("res://items/item use scenes/prefabs/Uplaceable.tscn")
