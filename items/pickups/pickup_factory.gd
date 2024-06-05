class_name PickupFactory
extends Node

@export var pickup_scene : PackedScene

static var instance : PickupFactory

func _init():
	instance = self

static func spawn_pickup(item : Item, position : Vector2):
	var created_pickup = instance.pickup_scene.instantiate()
	instance.add_child(created_pickup)
	created_pickup.enable(item, position)
