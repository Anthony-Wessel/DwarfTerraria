class_name ChunkSave
extends Resource

@export var tiles = []
@export var walls = []
@export var lights = []

static func create(_tiles, _walls, _lights):
	var new_chunk = ChunkSave.new()
	new_chunk.tiles = _tiles
	new_chunk.walls = _walls
	new_chunk.lights = _lights
	
	return new_chunk
