extends CharacterBody2D

@export var anim : AnimationPlayer
var anim_locked = false

var gravity = 200
var jump_force = -100
var speed = 25
var max_fall_speed = 700
var gravity_acceleration = 1.7

var player : Node2D

var stunned = false

func _process(delta):
	if player == null:
		player = Player.instance
		return
	
	
	var diff = player.position - position
	if !stunned:
		velocity.x = min(max(diff.x, -1), 1) * speed
	
	if diff.y < -1 or !$SpriteHolder/FloorDetector.is_floor_detected() or $SpriteHolder/ObstacleDetector.is_floor_detected():
		# try jumping
		if is_on_floor():
			velocity.y = jump_force
	
	if velocity.y > 0:
		velocity.y += gravity*delta*gravity_acceleration
	else:
		velocity.y += gravity*delta
	
	move_and_slide()
	
	if diff.x < 0:
		$SpriteHolder.scale.x = -1
	elif diff.x > 0:
		$SpriteHolder.scale.x = 1


func _on_hit():
	stunned = true
	
	await get_tree().create_timer(1.0).timeout
	
	stunned = false
