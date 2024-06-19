class_name LightManager
extends Node2D

static var instance : LightManager

var game_world : GameWorld
var world_size : Vector2
var sky_light_level := 30
var adjacents = [Vector2(0,1), Vector2(0,-1), Vector2(1,0), Vector2(-1,0)]

@export var multimesh : MultiMeshInstance2D
static var light_dict : Dictionary

static var indices = []

class LightInfo:
	var index := 0
	var value := 0
	var sky_value := 0
	var parent := Vector2.ZERO
	var sky_parent := Vector2.ZERO
	
	func _init(multimesh_index : int):
		index = multimesh_index
		value = -1
	
	func set_values(v : int, p : Vector2, s : int, sp : Vector2):
		value = v
		parent = p
		sky_value = s
		sky_parent = sp
		
		update()
	
	func update():
		var sky_light_lost = 30.0 - sky_value
		var color = Color(value, sky_light_lost, 0)
		LightManager.instance.multimesh.multimesh.set_instance_color(index, color)
	
	func reset():
		value = 0
		sky_value = 0
		parent = Vector2.ZERO
		sky_parent = Vector2.ZERO

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

static func setup_chunk(chunk_coords : Vector2):
	var index = claim_first_available_index()
	if index == null:
		if indices.size() > 0:
			push_error("all indices used")
		for i in instance.multimesh.multimesh.instance_count / 10000:
			indices.append(false)
		index = claim_first_available_index()
	var mesh_index = index * 10000

	#var chunk_position = chunk_coords * GlobalReferences.CHUNK_SIZE * GlobalReferences.TILE_SIZE
	for y in GlobalReferences.CHUNK_SIZE:
		for x in GlobalReferences.CHUNK_SIZE:
			#await Engine.get_main_loop().process_frame
			var coords = chunk_coords * GlobalReferences.CHUNK_SIZE + Vector2(x,y)
			light_dict[coords] = LightInfo.new(mesh_index)
			instance.calculate_light_level(coords)
			
			var tform = Transform2D(0, (coords+Vector2(0.5,0.5)) * GlobalReferences.TILE_SIZE)
			instance.multimesh.multimesh.set_instance_transform_2d(mesh_index, tform)
			
			mesh_index += 1
	
	return index
	

static func release_chunk(chunk_coords : Vector2, index : int):
	indices[index] = false
	
	for y in GlobalReferences.CHUNK_SIZE:
		for x in GlobalReferences.CHUNK_SIZE:
			var coords = chunk_coords * GlobalReferences.CHUNK_SIZE + Vector2(x,y)
			light_dict.erase(coords)


#################################
###### Handle light changes #####
#################################

func propagate_light(coords : Vector2):
	var tiles = [coords]
	while tiles.size() > 0:
		var current_coords = tiles[0]
		tiles.remove_at(0)
		if !calculate_light_level(current_coords):
			continue
		for offset in adjacents:
			var adjacent_coords = current_coords + offset
			if light_dict.has(adjacent_coords):
				tiles.append(adjacent_coords)

func recalculate_dependents(coords : Vector2):
	var tiles = []
	var unchecked_tiles = [coords]
	while unchecked_tiles.size() > 0:
		var t = unchecked_tiles[0]
		for offset in adjacents:
			var adjacent_coords = t.coordinates + offset
			if light_dict.has(adjacent_coords):
				if light_dict[adjacent_coords].parent == -offset or light_dict[adjacent_coords.sky_parent] == -offset:
					unchecked_tiles.append(adjacent_coords)
		
		light_dict[t].reset()
		unchecked_tiles.erase(t)
		tiles.append(t)
	
	for t in tiles:
		propagate_light(t)

func calculate_light_level(coords : Vector2) -> bool:
	var light_parent = Vector2.ZERO
	var sky_parent = Vector2.ZERO
	
	# light emitted by this tile)
	var tile_resource = game_world.get_tile(coords)
	var tile_value = tile_resource.light_source
	
	# sky light in this tile
	var sky_value = 0
	if game_world.is_tile_empty(coords):
		var wall_resource = game_world.get_wall(coords)
		if wall_resource.opacity == 0:
			sky_value = sky_light_level
	
	# check light from neighbors
	for offset in adjacents:
		if !light_dict.has(coords+offset):
			continue

		var light_info = light_dict[coords+offset]
		if light_info.sky_value - tile_resource.opacity > sky_value:
			sky_value = light_info.sky_value - tile_resource.opacity
			sky_parent = offset
		if light_info.value - tile_resource.opacity > tile_value:
			tile_value = light_info.value - tile_resource.opacity
			light_parent = offset
	
	# compare to old value and return
	var old_light_info = light_dict[coords]
	var updated = old_light_info.value != tile_value or old_light_info.sky_value != sky_value
	
	if updated:
		old_light_info.set_values(tile_value, light_parent, sky_value, sky_parent)
	
	return updated
