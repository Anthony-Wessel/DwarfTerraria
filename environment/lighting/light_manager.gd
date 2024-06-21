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
	instance.multimesh.material.set_shader_parameter("daylight", daylight)

static func update(coords : Vector2):
	instance.propagate_light(coords)

static func claim_first_available_index():
	for i in indices.size():
		if !indices[i]:
			indices[i] = true
			return i

static func setup_chunk(chunk_coords : Vector2, chunk : Chunk):
	var index = claim_first_available_index()
	if index == null:
		if indices.size() > 0:
			push_error("all indices used")
		for i in instance.multimesh.multimesh.instance_count / 10000:
			indices.append(false)
		index = claim_first_available_index()
	var mesh_index = index * 10000
	
	chunk.light_index = index
	
	#var chunk_position = chunk_coords * GlobalReferences.CHUNK_SIZE * GlobalReferences.TILE_SIZE
	for y in GlobalReferences.CHUNK_SIZE:
		for x in GlobalReferences.CHUNK_SIZE:
			#await Engine.get_main_loop().process_frame
			var coords = chunk_coords * GlobalReferences.CHUNK_SIZE + Vector2(x,y)
			#instance.calculate_light_level(coords)
			
			update_instance(coords)
			
			var tform = Transform2D(0, (coords+Vector2(0.5,0.5)) * GlobalReferences.TILE_SIZE)
			instance.multimesh.multimesh.set_instance_transform_2d(mesh_index, tform)
			
			mesh_index += 1

static func release_chunk(chunk_coords : Vector2, index : int):
	indices[index] = false

static func preload_lighting(game_save : GameSave):
	for y in game_save.get_height():
		for x in game_save.get_width():
			instance.propagate_light(Vector2(x,y), game_save)

#################################
###### Handle light changes #####
#################################

func propagate_light(coords : Vector2, world_data = game_world):
	var tiles = [coords]
	while tiles.size() > 0:
		var current_coords = tiles[0]
		tiles.remove_at(0)
		if !calculate_light_level(current_coords, world_data):
			continue
		for offset in adjacents:
			var adjacent_coords = current_coords + offset
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
		if world_data == game_world:
			update_instance(coords)
	
	return updated

static func update_instance(coords : Vector2i):
	var light_values = instance.game_world.get_light_values(coords)
	var sky_light_lost = 30.0 - light_values.y
	var color = Color(light_values.x, sky_light_lost, 0)
	var chunk_coords = coords / GlobalReferences.CHUNK_SIZE
	var inner_coords = coords % GlobalReferences.CHUNK_SIZE
	var chunk_light_index = instance.game_world.loaded_chunks[chunk_coords].light_index
	var index_offset = inner_coords.x + inner_coords.y * GlobalReferences.CHUNK_SIZE
	var index = chunk_light_index * 10000 + index_offset
	LightManager.instance.multimesh.multimesh.set_instance_color(index, color)
