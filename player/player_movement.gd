extends CharacterBody2D

@export var anim : AnimatedSprite2D
var anim_locked = false

var gravity = 200
var jump_force = -70
var speed = 75
var max_wall_slide_speed = 20
var max_fall_speed = 700
var gravity_acceleration = 1.7

func _physics_process(delta):
	_check_for_attack()
	_determine_horizontal_velocity(delta)
	_determine_vertical_velocity(delta)
	move_and_slide()
	_determine_animation()

func _determine_horizontal_velocity(delta):
	var horizontal = 0
	if Input.is_action_pressed("Right"):
		horizontal = 1
	elif Input.is_action_pressed("Left"):
		horizontal = -1
	
	if is_on_floor():
		velocity.x = horizontal*speed
	else:
		velocity.x = velocity.x + (horizontal * speed * 2 * delta)
		velocity.x = max(-speed, min(speed, velocity.x))
	
	if horizontal > 0:
		$SpriteHolder.scale.x = 1
	elif horizontal < 0:
		$SpriteHolder.scale.x = -1

func _determine_vertical_velocity(delta):
	# Determine Vertical Velocity
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor():
			velocity.y = jump_force
			if !anim_locked:
				anim.play("jump")
				anim_locked = true
		elif is_on_wall():
			velocity.y = jump_force
			velocity.x = get_wall_normal().x * speed
	else:
		if velocity.y > 0:
			velocity.y += gravity*delta*gravity_acceleration
		else:
			if Input.is_action_pressed("Jump"):
				velocity.y += gravity*delta*0.5
			else:
				velocity.y += gravity*delta
	
	if is_on_wall():
		velocity.y = min(max_wall_slide_speed, velocity.y)
	else:
		velocity.y = min(max_fall_speed, velocity.y)

func _determine_animation():
	if anim_locked:
		if !anim.is_playing():
			anim_locked = false
		else:
			return
	
	if is_on_floor():
		if velocity.length() > 0:
			_set_animation("run")
		else:
			_set_animation("idle")
	elif is_on_wall() and velocity.y > 0:
		_set_animation("open_door")
	else:
		_set_animation("airborne")

func _set_animation(new_anim : String):
	if anim.animation == new_anim:
		return
	
	anim.play(new_anim)

func _check_for_attack():
	if Input.is_action_just_pressed("mb_left"):
		if !anim_locked:
			anim.play("attack_slash")
			anim_locked = true
		elif _animation_percentage(anim.animation) > 0.5:
			if anim.animation == "attack_slash":
				anim.play("attack_sweep")
			else:
				anim.play("attack_slash")
	
	elif Input.is_action_just_pressed("mb_right"):
		if !anim_locked:
			anim.play("attack_stab")
			anim_locked = true
		elif _animation_percentage(anim.animation) > 0.5:
			if anim.animation == "attack_slash" or anim.animation == "attack_sweep":
				anim.play("attack_stab")

func _animation_percentage(animation : String) -> float:
	var temp = float(anim.frame) / anim.sprite_frames.get_frame_count(animation)
	return temp
