class_name EquipmentItem
extends Item

enum Type {
	HELMET,
	TORSO,
	LEGS,
	BOOTS,
	OFFHAND
}

@export var type : Type
@export var armor : int
@export var spritesheet : Texture2D

func get_use_scene():
	return null
