extends Node

signal dead

@export var max_health := 2
var health : int

func _ready():
	health = max_health

func handle_hit(damage : float, collision_position : Vector2):
	health -= damage
	if health <= 0:
		dead.emit()

func reset_health():
	health = max_health
