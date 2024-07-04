class_name ChunkSave
extends Resource

@export var tiles = []
@export var walls = []
@export var lights = []

@export var multiblocks = []

static func create(tiles, walls, lights):
	var new_chunk = ChunkSave.new()
	new_chunk.tiles = tiles
	new_chunk.walls = walls
	new_chunk.lights = lights
	
	return new_chunk
