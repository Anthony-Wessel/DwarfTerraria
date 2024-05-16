class_name FlyingMovement
extends CharacterBody2D

func update_velocity(new_velocity : Vector2):
	velocity = new_velocity

func _process(delta):
	if velocity.x < 0:
		$SpriteHolder.scale.x = -1
	elif velocity.x > 0:
		$SpriteHolder.scale.x = 1
	
	move_and_slide()

func handle_hit(_damage : float, collision_position : Vector2):
	var diff = global_position - collision_position
	update_velocity(Vector2(sign(diff.x)*70,-50))
