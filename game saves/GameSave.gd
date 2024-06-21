class_name GameSave
extends Resource

@export var horizontal_chunks := 18
@export var vertical_chunks := 9

func get_width():
	return horizontal_chunks * GlobalReferences.CHUNK_SIZE
func get_height():
	return vertical_chunks * GlobalReferences.CHUNK_SIZE

func get_chunk(coords: Vector2):
	return chunks[coords.x + coords.y*horizontal_chunks]

func get_tile(coords : Vector2i):
	return TileHandler.tiles[get_value(coords, 0)]
func get_wall(coords : Vector2i):
	return TileHandler.tiles[get_value(coords, 1)]
func get_light_values(coords : Vector2i):
	return get_value(coords, 2)

func set_light_values(coords : Vector2i, values : Vector2):
	var chunk_coords = coords / GlobalReferences.CHUNK_SIZE
	var inner_coords = coords % GlobalReferences.CHUNK_SIZE
	get_chunk(chunk_coords)[2][inner_coords.x + inner_coords.y * GlobalReferences.CHUNK_SIZE] = values

func get_value(coords : Vector2i, value_index : int):
	var chunk_coords = coords / GlobalReferences.CHUNK_SIZE
	var inner_coords = coords % GlobalReferences.CHUNK_SIZE
	return get_chunk(chunk_coords)[value_index][inner_coords.x + inner_coords.y * GlobalReferences.CHUNK_SIZE]

func contains_coordinates(coords : Vector2):
	return coords.x >= 0 and coords.y >= 0 and coords.x < get_width() and coords.y < get_height()

@export var chunks = []
@export var multiblocks = []
@export var player_spawn := Vector2(0,0)
@export var seed : int
