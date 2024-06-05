class_name LightManager
extends Node2D

static var instance : LightManager

var game_world : GameWorld
var world_size : Vector2
var sky_light_level := 30
var adjacents = [Vector2(0,1), Vector2(0,-1), Vector2(1,0), Vector2(-1,0)]

@export var multimesh : MultiMeshInstance2D
var light_dict : Dictionary

class LightInfo:
	var index := 0
	var value := 0
	var sky_value := 0
	var parent := Vector2.ZERO
	var sky_parent := Vector2.ZERO
	
	func _init(multimesh_index : int):
		index = multimesh_index
		value = -1
	
	func update(v : int, p : Vector2, s : int, sp : Vector2):
		value = v
		parent = p
		sky_value = s
		sky_parent = sp
		
		var color = Color.WHITE * max(value, sky_value)/30.0
		color.a = 1
		LightManager.update_mesh(index, color)
	
	func reset():
		value = 0
		sky_value = 0
		parent = Vector2.ZERO
		sky_parent = Vector2.ZERO

func _init():
	instance = self

static func update_mesh(index : int, color : Color):
	instance.multimesh.multimesh.set_instance_color(index, color)

static func update(coords : Vector2):
	instance.propagate_light(coords)

func initialize():
	game_world = GameWorld.instance
	world_size = Vector2(game_world.gameSave.width, game_world.gameSave.height)
	var index = 0
	for x in game_world.gameSave.width:
		for y in game_world.gameSave.height:
			var coords = Vector2(x,y)
			light_dict[coords] = LightInfo.new(index)
			
			calculate_light_level(coords)
			
			var tform = Transform2D(0, coords*8)
			multimesh.multimesh.set_instance_transform_2d(index, tform)
			
			index += 1
	
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
	
	# light emitted by this tile
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
		old_light_info.update(tile_value, light_parent, sky_value, sky_parent)
	
	return updated
