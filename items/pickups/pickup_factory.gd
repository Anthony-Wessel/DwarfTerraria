class_name PickupFactory
extends Node

@export var pickup_scene : PackedScene

static var Instance : PickupFactory

func _init():
	Instance = self

func spawn_pickup(item : Item, position : Vector2):
	var created_pickup = pickup_scene.instantiate()
	add_child(created_pickup)
	created_pickup.enable(item, position)
