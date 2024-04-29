class_name Player
extends Node2D

static var instance

@export var inventory : Node
@export var character_movement : CharacterMovement

func _init():
	instance = self

func _process(delta):
	if Input.is_action_pressed("Right"):
		character_movement.set_horizontal_movement(1)
	elif Input.is_action_pressed("Left"):
		character_movement.set_horizontal_movement(-1)
	else:
		character_movement.set_horizontal_movement(0)
	
	if Input.is_action_just_pressed("Jump"):
		character_movement.jump()
	elif Input.is_action_pressed("Jump"):
		character_movement.hold_jump()


func _on_attack_collision(body):
	body.get_child(0).get_hit(1, character_movement.position)
