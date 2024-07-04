class_name Chunk
extends Node2D

var tiles = []
var walls = []
var lights = []

var light_index

@export var tilemap : TileMap
@export var multimesh : MultiMeshInstance2D
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
			set_tile(Vector2(x,y), tile_resource)
			
			var wall_resource = TileHandler.tiles[walls[x + y * GlobalReferences.CHUNK_SIZE]]
			set_wall(Vector2(x,y), wall_resource)
			
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

func set_tile(coords : Vector2, tile_resource : TileResource):
	tiles[coords.x + coords.y * GlobalReferences.CHUNK_SIZE] = tile_resource.id
	tilemap.set_cell(0, coords, GameWorld.instance.tile_dict[tile_resource.name][0], GameWorld.instance.tile_dict[tile_resource.name][1])

func set_wall(coords : Vector2, tile_resource : TileResource):
	walls[coords.x + coords.y * GlobalReferences.CHUNK_SIZE] = tile_resource.id
	tilemap.set_cell(1, coords, GameWorld.instance.tile_dict[tile_resource.name][0], GameWorld.instance.tile_dict[tile_resource.name][1])

func set_light_values(coords : Vector2, light_values : Vector2):
	var mesh_index = coords.x + coords.y*GlobalReferences.CHUNK_SIZE
	lights[mesh_index] = light_values
	
	var sky_light_lost = 30.0 - lights[mesh_index].y
	var color = Color(lights[mesh_index].x, sky_light_lost, 0)
	LightManager.set_color((light_index * pow(GlobalReferences.CHUNK_SIZE, 2)) + mesh_index, color)

func get_tile(coords : Vector2):
	return tiles[coords.x + coords.y*GlobalReferences.CHUNK_SIZE]

func get_wall(coords : Vector2):
	return walls[coords.x + coords.y*GlobalReferences.CHUNK_SIZE]

func get_light_values(coords : Vector2):
	return lights[coords.x + coords.y * GlobalReferences.CHUNK_SIZE]

func _on_player_entered(_body):
	GameWorld.instance.player_entered_chunk(chunk_coords)
