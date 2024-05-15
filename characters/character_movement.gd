class_name CharacterMovement
extends CharacterBody2D

@export var sprite_holder : Node2D
@export var obstacle_detector : TileDetector

var gravity = 200
@export var jump_force = -70
@export var speed = 75
@export var max_wall_slide_speed = 20
var max_fall_speed = 700
var gravity_acceleration = 1.7
var jump_held = false

var horizontal := 0
var stun := false

func set_horizontal_movement(movement : int):
	horizontal = movement

func jump():
	if stun:
		return
	
	if is_on_floor():
		velocity.y = jump_force
	elif is_on_wall():
		velocity.y = jump_force
		velocity.x = get_wall_normal().x * speed
		

func hold_jump():
	jump_held = true

func force_velocity(force : Vector2):
	velocity = force
	
	stun = true
	await get_tree().create_timer(0.5).timeout
	stun = false
	

func _physics_process(delta):
	# HORIZONTAL
	if !stun:
		if is_on_floor():
			velocity.x = horizontal*speed
		else:
			velocity.x = velocity.x + (horizontal * speed * 2 * delta)
			velocity.x = max(-speed, min(speed, velocity.x))
	
	if horizontal > 0:
		$SpriteHolder.scale.x = 1
	elif horizontal < 0:
		$SpriteHolder.scale.x = -1
	
	if obstacle_detector.is_floor_detected() and is_on_floor() and is_on_wall() and horizontal != 0:
		var tile = obstacle_detector.detected_tiles[0] as Tile
		var up = tile.position/8 + Vector2(0,-1)
		var up2 = tile.position/8 + Vector2(0,-2)
		if GameWorld.instance.get_tile(up.x, up.y).empty and GameWorld.instance.get_tile(up2.x, up2.y).empty:
			position = position + Vector2(0,-8.1)
			var tween = get_tree().create_tween()
			$SpriteHolder.position = Vector2(0,8)
			tween.tween_property($SpriteHolder, "position", Vector2.ZERO, 0.1)
	
	
	# VERTICAL
	if velocity.y > 0:
		velocity.y += gravity*delta*gravity_acceleration
	elif jump_held == true:
		velocity.y += gravity*delta*0.5
	else:
		velocity.y += gravity*delta
	
	
	move_and_slide()
	jump_held = false

func handle_hit(_damage : float, collision_position : Vector2):
	var diff = global_position - collision_position
	force_velocity(Vector2(sign(diff.x)*70,-50))
