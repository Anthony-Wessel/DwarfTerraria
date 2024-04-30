class_name HeldItem
extends Node2D

@export var anim : AnimationPlayer

signal collision_detected(body)

func use(speed : float):
	anim.play("use", -1, speed)

func _collision_detected(body):
	print("test2")
	collision_detected.emit(body)
