extends Node2D

@export var border_prefab : PackedScene

func _init():
	GameWorld.instance.world_finished_loading.connect(create_border)

func create_border():
	var game_world = get_parent() as GameWorld
	var world_size = Vector2(game_world.gameSave.get_width(), game_world.gameSave.get_height()) * GlobalReferences.TILE_SIZE
	
	var vertical_rect = Vector2(10, world_size.y)
	var horizontal_rect = Vector2(world_size.x, 10)
	
	var left_border = border_prefab.instantiate()
	add_child(left_border)
	left_border.setup(vertical_rect, Vector2(-5, world_size.y/2))
	
	var right_border = border_prefab.instantiate()
	add_child(right_border)
	right_border.setup(vertical_rect, Vector2(world_size.x+5, world_size.y/2))
	
	var top_border = border_prefab.instantiate()
	add_child(top_border)
	top_border.setup(horizontal_rect, Vector2(world_size.x/2, -5))
	
	var bottom_border = border_prefab.instantiate()
	add_child(bottom_border)
	bottom_border.setup(horizontal_rect, Vector2(world_size.x/2, world_size.y+5))

