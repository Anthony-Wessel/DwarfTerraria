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

@export var chunks = []
@export var multiblocks = []
@export var player_spawn := Vector2(0,0)
@export var seed : int
