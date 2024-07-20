class_name ToolItem
extends Item

@export var mining_tier := 0
@export var mining_speed := 1.0
@export var mines_walls := false

func get_use_scene():
	return preload("res://items/item use scenes/prefabs/Utool.tscn")
