class_name GameWorld
extends Node2D

static var instance : GameWorld

var gameSave : GameSave
@export var player : CharacterMovement

@export var tile_set : TileSet
@export var chunk_prefab : PackedScene

var tile_dict : Dictionary

var loaded_chunks = {}
var ready_chunks = []

signal world_finished_loading
var loading_world = true

var save_frequency = 1 # times per second
var last_save_time = 0

func _init():
	instance = self

func _ready():
	generate_tile_dict()
	load_game()

var chunk_save_index = 0
func _process(_delta):
	if loading_world:
		return
	
	load_ready_chunks()
	if Time.get_ticks_msec() - last_save_time > save_frequency * 100:
		chunk_save_index = (chunk_save_index+1) % loaded_chunks.size()
		
		if chunk_save_index == 0:
			gameSave.save_player()
		
		var coords = loaded_chunks.keys()[chunk_save_index]
		save_chunk(coords)
		last_save_time = Time.get_ticks_msec()

func generate_tile_dict():
	for source_index in tile_set.get_source_count():
		var source_id = tile_set.get_source_id(source_index)
		var source : TileSetAtlasSource = tile_set.get_source(source_id)
		if source == null:
			continue
		
		for tile_index in source.get_tiles_count():
			var coords := source.get_tile_id(tile_index)
			var tile_data = source.get_tile_data(coords, 0)
			var tile_name = tile_data.get_custom_data_by_layer_id(0)
			tile_dict[tile_name] = [source_id, coords]

func load_game():
	# Create new game save
	#gameSave = await GameSave.create_new_world("Test World", Vector2i(9,9))
	
	# Load game save
	gameSave = GameSave.load_world("Test World")

	
	var player_spawn = gameSave.world_info.player_spawn
	var player_spawn_chunk : Vector2i = player_spawn / GlobalReferences.CHUNK_SIZE
	for y in range(-1,2): # inclusive start, exclusive end
		for x in range(-1,2):
			var coords = player_spawn_chunk + Vector2i(x,y)
			load_chunk(coords)
	
	player.global_position = player_spawn * GlobalReferences.TILE_SIZE
	
	loading_world = false
	world_finished_loading.emit()
	print("World done loading")

func load_ready_chunks():
	if ready_chunks.size() > 0:
		load_chunk(ready_chunks[0])
		ready_chunks.remove_at(0)

func load_chunk(coords : Vector2i):
	if loaded_chunks.has(coords):
		push_error("Trying to load chunk that already exists")
		return
	var chunk : Chunk = chunk_prefab.instantiate()
	chunk.position = coords * GlobalReferences.CHUNK_SIZE * GlobalReferences.TILE_SIZE
	chunk.initialize(gameSave.get_chunk(coords), coords)
	
	loaded_chunks[coords] = chunk
	add_child.call_deferred(chunk)

func unload_chunk(coords : Vector2i):
	save_chunk(coords)
	loaded_chunks[coords].unload()
	loaded_chunks.erase(coords)

func player_entered_chunk(chunk_coords : Vector2i):
	if loading_world:
		return
	var chunks_to_load = []
	var chunks_to_unload = []
	var new_set = []
	for y in range(-2,3): # inclusive start, exclusive end
		for x in range(-2,3):
			var coords = chunk_coords + Vector2i(x,y)
			coords.x = max(min(coords.x, gameSave.world_info.size.x-1), 0)
			coords.y = max(min(coords.y, gameSave.world_info.size.y-1), 0)
			
			if !loaded_chunks.has(coords):
				chunks_to_load.append(coords)
			new_set.append(coords)
	
	for old_chunk in loaded_chunks:
		if !new_set.has(old_chunk):
			chunks_to_unload.append(old_chunk)
	
	for coords in chunks_to_unload:
		unload_chunk(coords)
	
	for coords in chunks_to_load:
		if !ready_chunks.has(coords):
			ready_chunks.append(coords)

func is_tile_empty(coords : Vector2i) -> bool:
	var chunk_coords : Vector2i = coords / GlobalReferences.CHUNK_SIZE
	if loaded_chunks.has(chunk_coords):
		return loaded_chunks[chunk_coords].get_tile(coords % int(GlobalReferences.CHUNK_SIZE)) == 0
	
	return true

func is_wall_empty(coords : Vector2i) -> bool:
	var chunk_coords : Vector2i = coords / GlobalReferences.CHUNK_SIZE
	if loaded_chunks.has(chunk_coords):
		return loaded_chunks[chunk_coords].get_wall(coords % int(GlobalReferences.CHUNK_SIZE)) == 8
	
	return true

func get_player_spawn():
	return gameSave.player_spawn


func get_tile(coords : Vector2i) -> TileResource:
	var chunk_coords : Vector2i = coords / GlobalReferences.CHUNK_SIZE
	if loaded_chunks.has(chunk_coords):
		var id = loaded_chunks[chunk_coords].get_tile(coords % GlobalReferences.CHUNK_SIZE)
		return TileHandler.tiles[id]
	
	return null

func get_wall(coords : Vector2i) -> TileResource:
	var chunk_coords : Vector2i = coords / GlobalReferences.CHUNK_SIZE
	if loaded_chunks.has(chunk_coords):
		var id = loaded_chunks[chunk_coords].get_wall(coords % GlobalReferences.CHUNK_SIZE)
		return TileHandler.tiles[id]
	
	return null


func break_tile(coords : Vector2, wall : bool):
	var tile_resource
	if wall:
		tile_resource = get_wall(coords)
		set_tile(coords, TileHandler.EMPTY_WALL)
	else:
		tile_resource = get_tile(coords)
		set_tile(coords, TileHandler.EMPTY_TILE)
	
	if tile_resource.dropped_item != null:
		PickupFactory.spawn_pickup(tile_resource.dropped_item, coords * GlobalReferences.TILE_SIZE + Vector2(4,4))
	
	update_neighbors(coords, wall)

var neighbor_offsets = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
func update_neighbors(coords : Vector2i, wall : bool):
	await get_tree().create_timer(0.02).timeout
	for offset in neighbor_offsets:
		update(coords+offset, wall)

func update(coords : Vector2, wall : bool):
	var tile_resource : TileResource
	if wall : tile_resource = get_wall(coords)
	else: tile_resource = get_tile(coords)
	
	if tile_resource == null:
		return
	
	if tile_resource.potential_supports.size() > 0:
		var support_found := false
		for support in tile_resource.potential_supports:
			if wall:
				var wall_resource = get_wall(coords+support)
				if wall_resource != TileHandler.EMPTY_WALL and wall_resource != null:
					support_found = true
					break
			else:
				var t_resource = get_tile(coords+support)
				if t_resource != TileHandler.EMPTY_TILE and t_resource != null:
					support_found = true
					break
		
		if !support_found:
			break_tile(coords, wall)

func set_tile(coords : Vector2i, tile_resource : TileResource):
	var chunk_coords = coords / GlobalReferences.CHUNK_SIZE
	var chunk = loaded_chunks[chunk_coords]
	chunk.set_tile(coords % GlobalReferences.CHUNK_SIZE, tile_resource)
	
	LightManager.update(coords)

func place_item(coords : Vector2, item : PlaceableItem, place_tiles : bool):
	if place_tiles:
		for i in item.tile_ids.size():
			var tile_resource = TileHandler.tiles[item.tile_ids[i]]
			@warning_ignore("integer_division")
			var offset = Vector2(i%item.size.x, i/item.size.x)
			
			set_tile(coords+offset, tile_resource)

func get_light_values(coords : Vector2i):
	var chunk_coords = coords / GlobalReferences.CHUNK_SIZE
	var inner_coords = coords % GlobalReferences.CHUNK_SIZE
	return loaded_chunks[chunk_coords].get_light_values(inner_coords)

func set_light_values(coords : Vector2i, values : Vector2):
	var chunk_coords = coords / GlobalReferences.CHUNK_SIZE
	var inner_coords = coords % GlobalReferences.CHUNK_SIZE
	loaded_chunks[chunk_coords].set_light_values(inner_coords, values)

func contains_coordinates(coords : Vector2):
	return gameSave.contains_coordinates(coords)

func global_to_tile_coordinates(global_coords : Vector2):
	return (global_coords - global_position)/GlobalReferences.TILE_SIZE

func save_chunk(chunk_coords : Vector2i):
	var chunk = null
	if loaded_chunks.has(chunk_coords):
		chunk = loaded_chunks[chunk_coords]
	gameSave.save_chunk(chunk_coords, chunk)
