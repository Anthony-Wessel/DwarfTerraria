class_name WeaponItem
extends Item

@export var damage := 1.0
@export var speed := 1.0
@export var collision_shape : Rect2
@export var use_scene : PackedScene

func get_use_scene():
	return use_scene
