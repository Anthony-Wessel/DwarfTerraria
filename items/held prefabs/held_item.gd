class_name HeldItem
extends Node2D

@export var anim : AnimationPlayer
@export var collider_shape : CollisionShape2D

signal collision_detected(body)

func use(animation : String, speed : float):
	anim.play(animation, -1, speed)

func _collision_detected(body):
	collision_detected.emit(body)

func set_collision(collider_data : Rect2):
	var rect = collider_shape.shape as RectangleShape2D
	rect.size = Vector2(collider_data.size.x, collider_data.size.y)
	collider_shape.position = collider_data.position

func set_sprite(sprite : Texture):
	$Sprite2D.texture = sprite
