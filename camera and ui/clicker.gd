extends Node

@export var tileGrid : GameWorld
@export var tile_resources : Array[TileRes]

var tile_resources_index := 0

func _input(event):
	var mb_event = event as InputEventMouseButton
	if !mb_event:
		return
	
	if !mb_event.pressed:
		return

	var tile_pos = Vector2i(tileGrid.get_local_mouse_position()/8)

	if mb_event.button_index == 4:
		tile_resources_index += 1
		if tile_resources_index >= tile_resources.size():
			tile_resources_index = 0
		$MarginContainer/TileSelector.texture = tile_resources[tile_resources_index].texture
	elif mb_event.button_index == 5:
		tile_resources_index -= 1
		if tile_resources_index < 0:
			tile_resources_index = tile_resources.size()-1
		$MarginContainer/TileSelector.texture = tile_resources[tile_resources_index].texture
	
	elif mb_event.button_index == 1:
		tileGrid.set_tile(tile_pos.x ,tile_pos.y, null)
	elif mb_event.button_index == 2:
		tileGrid.set_tile(tile_pos.x ,tile_pos.y, tile_resources[tile_resources_index])
