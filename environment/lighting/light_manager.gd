class_name LightManager
extends Node2D

static var instance : LightManager

var game_world : GameWorld
var world_size : Vector2
var sky_light_level := 30
var adjacents = [Vector2(0,1), Vector2(0,-1), Vector2(1,0), Vector2(-1,0)]

@export var multimesh : MultiMeshInstance2D

static var indices = []

func _init():
	instance = self

func _ready():
	game_world = GameWorld.instance

func _process(_delta):
	if DayNightCycle.instance.is_shifting():
		set_daylight(DayNightCycle.instance.get_daylight())

func set_daylight(daylight : float):
	for child in get_children():
		child.material.set_shader_parameter("daylight", daylight)

static func update(coords : Vector2):
	instance.propagate_light(coords)

static func claim_first_available_index():
	if indices.size() == 0:
		for i in instance.multimesh.multimesh.instance_count / pow(GlobalReferences.CHUNK_SIZE, 2):
			indices.append(false)
	
	for i in indices.size():
		if !indices[i]:
			indices[i] = true
			return i
	
	print("not enough light indices available")
	print(GameWorld.instance.loaded_chunks.size(), " chunks loaded")

static func release_index(index : int):
	indices[index] = false

static func set_tform(index : int, transform2D : Transform2D):
	instance.multimesh.multimesh.set_instance_transform_2d(index, transform2D)

static func set_color(index : int, color : Color):
	instance.multimesh.multimesh.set_instance_color(index, color)

static func preload_lighting(game_save : GameSave):
	for y in game_save.get_height():
		for x in game_save.get_width():
			instance.propagate_light(Vector2(x,y), game_save)

#################################
###### Handle light changes #####
#################################
var time
func propagate_light(coords : Vector2, world_data = game_world):
	var checked_tiles = []

	var tiles = [coords]
	while tiles.size() > 0:
		var current_coords = tiles[0]
		tiles.remove_at(0)
		checked_tiles.append(current_coords)
		if !calculate_light_level(current_coords, world_data):
			continue
		for offset in adjacents:
			var adjacent_coords = current_coords + offset
			if checked_tiles.has(adjacent_coords):
				continue
			if world_data.contains_coordinates(adjacent_coords):
				tiles.append(adjacent_coords)

func calculate_light_level(coords : Vector2, world_data = game_world) -> bool:
	# light emitted by this tile
	var tile_resource = world_data.get_tile(coords)
	var tile_value = tile_resource.light_source
	
	# sky light in this tile
	var sky_value = 0
	if tile_resource == TileHandler.EMPTY_TILE:
		var wall_resource = world_data.get_wall(coords)
		if wall_resource.opacity == 0:
			sky_value = sky_light_level
	
	# check light from neighbors
	for offset in adjacents:
		if !world_data.contains_coordinates(coords+offset):
			continue
			
		var light_value = world_data.get_light_values(coords+offset)
		if light_value.y - tile_resource.opacity > sky_value:
			sky_value = light_value.y - tile_resource.opacity
		if light_value.x - tile_resource.opacity > tile_value:
			tile_value = light_value.x - tile_resource.opacity

	
	# compare to old value and return
	var old_light_values = world_data.get_light_values(coords)
	var updated = old_light_values.x != tile_value or old_light_values.y != sky_value
	if updated:
		world_data.set_light_values(coords, Vector2(tile_value, sky_value))
	
	return updated
