extends Node2D

@export var player : CharacterMovement

func _process(delta):
	position = player.sprite_holder.global_position
