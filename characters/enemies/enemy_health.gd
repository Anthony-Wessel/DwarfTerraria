extends Node

@export var hitbox : Hitbox
@export var health := 2

func _ready():
	hitbox.hit.connect(handle_hit)

func handle_hit(damage : float, collision_position : Vector2):
	health -= damage
	if health <= 0:
		get_parent().queue_free()
