class_name WorldInfo
extends Resource

@export var world_seed : int
@export var name : String
@export var size : Vector2i
@export var player_spawn : Vector2

static func create(name : String, size : Vector2i):
	var new_info = WorldInfo.new()
	new_info.name = name
	new_info.size = size
	new_info.world_seed = RandomNumberGenerator.new().randi()
	
	return new_info
