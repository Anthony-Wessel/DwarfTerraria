extends Node2D

@export var start_angle := -20.0
@export var end_angle := 90.0
@export var time := 0.25

func _ready():
	var item = InventoryInterface.get_selected_item()
	$Sprite2D.texture = item.texture
	
	var tween = get_tree().create_tween()
	rotation_degrees = start_angle
	tween.tween_property(self, "rotation_degrees", end_angle, time)
	
	await tween.finished
	
	queue_free()
