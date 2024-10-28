class_name Health
extends Node

signal damaged
signal dead

@export var is_player := false

@export var max_health := 2
var health : float

func _ready():
	health = max_health

func handle_hit(damage : int, _collision_position : Vector2):
	if is_player:
		var armor := 0.0
		for slot in InventoryInterface.player_equipment.contents:
			if slot.contents.item != null:
				armor += slot.contents.item.armor
		health -= damage/(1.0+ 0.2*armor)
	else:
		health -= damage
	if health <= 0:
		dead.emit()
	damaged.emit()

func reset_health():
	health = max_health

func get_percent_health():
	return health / max_health
