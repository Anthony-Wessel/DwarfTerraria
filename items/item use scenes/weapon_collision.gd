extends Node2D

func _on_body_entered(body):
	var diff = body.global_position - global_position
	(body as CharacterMovement).force_velocity(Vector2(sign(diff.x)*70,-50))
