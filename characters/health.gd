class_name Health
extends Node

signal damaged
signal dead

@export var max_health := 2
var health : int

func _ready():
	health = max_health

func handle_hit(damage : int, _collision_position : Vector2):
	health -= damage
	if health <= 0:
		dead.emit()
	damaged.emit()

func reset_health():
	health = max_health

func get_percent_health():
	return float(health) / max_health
