extends Node2D

@export var start_angle := -20.0
@export var end_angle := 90.0
@export var time := 0.25


func _ready():
	# Setup
	var tile_grid = GameWorld.instance
	var item = InventoryInterface.get_selected_item() as PlaceableItem
	$Sprite2D.texture = item.texture
	
	var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/GlobalReferences.TILE_SIZE)
	if !tile_grid.place_item(tile_pos, item):
		queue_free()
		return
	
	InventoryInterface.used_selected_item()
	
	# Swing (cooldown)
	var tween = get_tree().create_tween()
	rotation_degrees = start_angle
	tween.tween_property(self, "rotation_degrees", end_angle, time)
	
	# Wait for swing to finish
	await tween.finished
	
	# cleanup
	queue_free()
