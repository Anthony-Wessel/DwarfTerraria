class_name Hitbox
extends Area2D

signal hit(damage : float, collision_position : Vector2)

func handle_hit(damage : float, collision_position : Vector2):
	hit.emit(damage, collision_position)
