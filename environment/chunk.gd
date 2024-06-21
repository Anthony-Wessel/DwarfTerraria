class_name Chunk
extends Node2D

var tiles = []
var walls = []
var lights = []

@export var tilemap : TileMap
var coords : Vector2i
var light_index

func initialize(chunk_info, chunk_coords : Vector2i):
	#var time = Time.get_ticks_msec()
	tiles = chunk_info[0]
	walls = chunk_info[1]
	lights = chunk_info[2]
	coords = chunk_coords
	
	#print(Time.get_ticks_msec() - time)
	#time = Time.get_ticks_msec()
	for y in GlobalReferences.CHUNK_SIZE:
		#await Engine.get_main_loop().process_frame
		for x in GlobalReferences.CHUNK_SIZE:
			var tile_resource = TileHandler.tiles[tiles[x + y * GlobalReferences.CHUNK_SIZE]]
			set_tile(Vector2(x,y), tile_resource)
			
			var wall_resource = TileHandler.tiles[walls[x + y * GlobalReferences.CHUNK_SIZE]]
			set_wall(Vector2(x,y), wall_resource)
	
	#print(Time.get_ticks_msec() - time)
	#time = Time.get_ticks_msec()
	
	#light_index = await LightManager.setup_chunk(coords)
	LightManager.setup_chunk(coords, self)
	
	#print(Time.get_ticks_msec() - time)
	#time = Time.get_ticks_msec()
	

func set_tile(coords : Vector2, tile_resource : TileResource):
	tiles[coords.x + coords.y * GlobalReferences.CHUNK_SIZE] = tile_resource.id
	tilemap.set_cell(0, coords, GameWorld.instance.tile_dict[tile_resource.name][0], GameWorld.instance.tile_dict[tile_resource.name][1])

func set_wall(coords : Vector2, tile_resource : TileResource):
	walls[coords.x + coords.y * GlobalReferences.CHUNK_SIZE] = tile_resource.id
	tilemap.set_cell(1, coords, GameWorld.instance.tile_dict[tile_resource.name][0], GameWorld.instance.tile_dict[tile_resource.name][1])

func set_light_values(coords : Vector2, light_values : Vector2):
	lights[coords.x + coords.y * GlobalReferences.CHUNK_SIZE] = light_values


func get_tile(coords : Vector2):
	return tiles[coords.x + coords.y*GlobalReferences.CHUNK_SIZE]

func get_wall(coords : Vector2):
	return walls[coords.x + coords.y*GlobalReferences.CHUNK_SIZE]

func get_light_values(coords : Vector2):
	return lights[coords.x + coords.y * GlobalReferences.CHUNK_SIZE]

func _on_player_entered(body):
	GameWorld.instance.player_entered_chunk(coords)
