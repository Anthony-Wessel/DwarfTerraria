class_name DynamicLights
extends Node2D

static var instance : DynamicLights

func _ready():
	instance = self

static func attach_light(light : Node2D):
	light.reparent.call_deferred(instance, true)
