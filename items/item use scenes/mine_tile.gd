extends Node2D

@export var start_angle := -20.0
@export var end_angle := 90.0

var corner_offsets = [Vector2(-3,-3), Vector2(3,-3), Vector2(3,3), Vector2(-3,3)]

func _ready():
	# Setup
	var tool = InventoryInterface.get_selected_item() as ToolItem
	if !tool:
		push_error("tool prefab being used with non-tool item")
		return
		
	$Sprite2D.texture = tool.texture
	var tile_grid = GameWorld.instance
	var targeted_tiles : Array[Vector2i]
	
	# Swing tool
	var tween = get_tree().create_tween()
	rotation_degrees = start_angle
	tween.tween_property(self, "rotation_degrees", end_angle, 1/tool.mining_speed)
	
	# Wait for swing to finish
	await tween.finished
	
	# mine tile
	if Input.is_key_pressed(KEY_SHIFT):
		for offset in corner_offsets:
			var corner = Vector2i((tile_grid.get_local_mouse_position() + offset)/GlobalReferences.TILE_SIZE)
			if !targeted_tiles.has(corner):
				targeted_tiles.append(corner)
	else:
		targeted_tiles = [Vector2i(tile_grid.get_local_mouse_position()/GlobalReferences.TILE_SIZE)]
	
	for tile_pos in targeted_tiles:
		var distance_to_player = global_position - (Vector2(tile_pos)*GlobalReferences.TILE_SIZE)
		if distance_to_player.length() > 5*GlobalReferences.TILE_SIZE:
			targeted_tiles.erase(tile_pos)
	
	Miner.instance.mine_tile(targeted_tiles, tool.mining_tier, tool.mining_speed, tool.mines_walls)
	
	# cleanup
	queue_free()
