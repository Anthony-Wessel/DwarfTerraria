class_name CharacterMovement
extends CharacterBody2D

@export var sprite_holder : Node2D

var gravity = 200
@export var jump_force = -70
@export var speed = 75
@export var max_wall_slide_speed = 20
var max_fall_speed = 700
var gravity_acceleration = 1.7
var jump_held = false

var horizontal := 0

func set_horizontal_movement(movement : int):
	horizontal = movement

func jump():
	if is_on_floor():
		velocity.y = jump_force
	elif is_on_wall():
		velocity.y = jump_force
		velocity.x = get_wall_normal().x * speed
		

func hold_jump():
	jump_held = true

func _physics_process(delta):
	# HORIZONTAL
	if is_on_floor():
		velocity.x = horizontal*speed
	else:
		velocity.x = velocity.x + (horizontal * speed * 2 * delta)
		velocity.x = max(-speed, min(speed, velocity.x))
	
	if horizontal > 0:
		$SpriteHolder.scale.x = 1
	elif horizontal < 0:
		$SpriteHolder.scale.x = -1
	
	
	# VERTICAL
	if velocity.y > 0:
		velocity.y += gravity*delta*gravity_acceleration
	elif jump_held == true:
		velocity.y += gravity*delta*0.5
	else:
		velocity.y += gravity*delta
	
	
	move_and_slide()
	jump_held = false