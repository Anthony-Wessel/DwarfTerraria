class_name Chunk
extends Node2D

var tiles = []
var walls = []
var lights = []

var light_index

@export var tilemap : TileMap
@export var entity_root : Node2D
var chunk_coords : Vector2i

func initialize(chunk_info, chunk_coordinates : Vector2i):
	tiles = chunk_info.tiles
	walls = chunk_info.walls
	lights = chunk_info.lights
	chunk_coords = chunk_coordinates
	
	light_index = LightManager.claim_first_available_index()
	for y in GlobalReferences.CHUNK_SIZE:
		#await Engine.get_main_loop().process_frame
		for x in GlobalReferences.CHUNK_SIZE:
			var tile_resource = TileHandler.tiles[tiles[x + y * GlobalReferences.CHUNK_SIZE]]
			var entity_data = {}
			if chunk_info.entity_data.keys().has(Vector2i(x,y)):
				entity_data = chunk_info.entity_data[Vector2i(x,y)]
			set_tile(Vector2(x,y), tile_resource, entity_data)
			
			var wall_resource = TileHandler.tiles[walls[x + y * GlobalReferences.CHUNK_SIZE]]
			set_tile(Vector2(x,y), wall_resource)
			
			var mesh_index = x + y * GlobalReferences.CHUNK_SIZE
			var mesh_coords : Vector2i = chunk_coords * GlobalReferences.CHUNK_SIZE + Vector2i(x,y)
			
			var tform = Transform2D(0, (Vector2(mesh_coords)+Vector2(0.5,0.5)) * GlobalReferences.TILE_SIZE)
			LightManager.set_tform((light_index * pow(GlobalReferences.CHUNK_SIZE, 2)) + mesh_index, tform)
			
			var sky_light_lost = 30.0 - lights[mesh_index].y
			var color = Color(lights[mesh_index].x, sky_light_lost, 0)
			LightManager.set_color((light_index * pow(GlobalReferences.CHUNK_SIZE, 2)) + mesh_index, color)

func unload():
	LightManager.release_index(light_index)
	queue_free()

func set_tile(coords : Vector2i, tile_resource : TileResource, entity_data : Dictionary = {}):
	var tilemap_layer
	var list
	if tile_resource.wall:
		list = walls
		tilemap_layer = 1
	else:
		list = tiles
		tilemap_layer = 0
	
	list[coords.x + coords.y * GlobalReferences.CHUNK_SIZE] = tile_resource.id
	tilemap.set_cell(tilemap_layer, coords, GameWorld.instance.tile_dict[tile_resource.name][0], GameWorld.instance.tile_dict[tile_resource.name][1])
	
	if tile_resource.entity_prefab != null:
		var entity = tile_resource.entity_prefab.instantiate()
		entity.position = coords * GlobalReferences.TILE_SIZE
		entity_root.add_child(entity)
		
		entity.setup(GameWorld.instance, chunk_coords * GlobalReferences.CHUNK_SIZE + coords, tile_resource)
		if entity_data != {}:
			entity.load_data(entity_data)

func set_light_values(coords : Vector2, light_values : Vector2):
	var mesh_index = coords.x + coords.y*GlobalReferences.CHUNK_SIZE
	lights[mesh_index] = light_values
	
	var sky_light_lost = 30.0 - lights[mesh_index].y
	var color = Color(lights[mesh_index].x, sky_light_lost, 0)
	LightManager.set_color((light_index * pow(GlobalReferences.CHUNK_SIZE, 2)) + mesh_index, color)

func get_tile(coords : Vector2, wall : bool):
	if wall:
		return walls[coords.x + coords.y*GlobalReferences.CHUNK_SIZE]
	else:
		return tiles[coords.x + coords.y*GlobalReferences.CHUNK_SIZE]

func get_light_values(coords : Vector2):
	return lights[coords.x + coords.y * GlobalReferences.CHUNK_SIZE]

func save_entities() -> Dictionary:
	var result = {}
	
	for entity in entity_root.get_children():
		var entity_data = entity.save_data()
		if entity_data != {}:
			var coords : Vector2i = entity.position / GlobalReferences.TILE_SIZE
			result[coords] = entity_data
		
	return result
