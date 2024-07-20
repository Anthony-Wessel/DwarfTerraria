class_name WorldInfo
extends Resource

@export var world_seed : int
@export var name : String
@export var size : Vector2i
@export var player_spawn : Vector2

static func create(_name : String, _size : Vector2i):
	var new_info = WorldInfo.new()
	new_info.name = _name
	new_info.size = _size
	new_info.world_seed = RandomNumberGenerator.new().randi()
	
	return new_info
