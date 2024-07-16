extends Node2D

@export var start_angle := -20.0
@export var end_angle := 90.0
@export var time := 0.25


func _ready():
	# Setup
	var tile_grid = GameWorld.instance
	var item = ItemUser.instance.held_item
	$Sprite2D.texture = item.texture
	
	# Check if can place tile
	var intersections = ItemUser.instance.preview_intersections
	if item is TileItem:
		if intersections[0]:
			queue_free()
			return
		else:
			tile_grid.place_tile(ItemUser.instance.prev_pos, item)
			ItemUser.instance.inventory.remove_item(item)
			ItemUser.instance.update_preview_sprite(ItemUser.instance.prev_pos)
	else:
		var multiblock = item as MultiblockItem
		for x in multiblock.size.x:
			for y in multiblock.size.y:
				if intersections[x + y * multiblock.size.x]:
					queue_free()
					return
		
		tile_grid.place_multiblock(ItemUser.instance.prev_pos, multiblock, true)
		ItemUser.instance.inventory.remove_item(multiblock)
		ItemUser.instance.update_preview_sprite(ItemUser.instance.prev_pos)
	
	
	# Swing (cooldown)
	var tween = get_tree().create_tween()
	rotation_degrees = start_angle
	tween.tween_property(self, "rotation_degrees", end_angle, time)
	
	# Wait for swing to finish
	await tween.finished
	
	# cleanup
	queue_free()
