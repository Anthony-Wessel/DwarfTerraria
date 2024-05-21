extends Node

signal dead

@export var max_health := 2
var health := 2

func handle_hit(damage : float, collision_position : Vector2):
	health -= damage
	if health <= 0:
		dead.emit()

func reset_health():
	health = max_health
