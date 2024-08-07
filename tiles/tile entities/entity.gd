class_name Entity
extends Node2D

var tile_coords : Vector2i
var world : GameWorld
var tile : TileResource

func setup(game_world : GameWorld, coords : Vector2i, main_tile):
	tile_coords = coords
	world = game_world
	tile = main_tile

func _process(_delta):
	if world.get_tile(tile_coords, tile.wall) != tile:
		queue_free()

func save_data() -> Dictionary:
	return {}

@warning_ignore("unused_parameter")
func load_data(entity_data : Dictionary):
	pass
