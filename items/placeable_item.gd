class_name PlaceableItem
extends Item

@export var size : Vector2i
@export var tile_ids : Array[int]

func get_use_scene():
	return preload("res://items/item use scenes/prefabs/Uplaceable.tscn")
