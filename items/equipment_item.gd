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

func get_use_scene():
	return null
