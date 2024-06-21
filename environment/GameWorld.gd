class_name GameWorld
extends Node2D

static var instance : GameWorld

var gameSave : GameSave
@export var player : CharacterMovement

@export var multiblocks_root : Node2D

@export var tile_set : TileSet
@export var chunk_prefab : PackedScene

var tile_dict : Dictionary

var loaded_chunks = {}

signal world_finished_loading
var loading_world = true

var save_frequency = 1 # times per second
var last_save_time = 0

func _init():
	instance = self

func _ready():
	generate_tile_dict()
	load_game()

func _process(_delta):
	if Time.get_ticks_msec() - last_save_time > save_frequency * 1000:
		save_game()
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
	gameSave = GameSave.new()
	gameSave.vertical_chunks = 9
	gameSave.horizontal_chunks = 18
	await WorldGenerator.GenerateWorld(gameSave)
	
	# Load game save
	#gameSave = ResourceLoader.load("res://game saves/game_save_resource.tres")
	
	var player_spawn = gameSave.player_spawn
	var player_spawn_chunk : Vector2i = player_spawn / GlobalReferences.CHUNK_SIZE
	for y in range(-1,2): # inclusive start, exclusive end
		for x in range(-1,2):
			var coords = player_spawn_chunk + Vector2i(x,y)
			load_chunk(coords)

	player.global_position = player_spawn * GlobalReferences.TILE_SIZE
	
	world_finished_loading.emit()
	loading_world = false
	print("World done loading")

func load_chunk(coords : Vector2i):
	#print("loading chunk")
	var chunk : Chunk = chunk_prefab.instantiate()
	add_child(chunk)
	chunk.position = coords * GlobalReferences.CHUNK_SIZE * GlobalReferences.TILE_SIZE
	loaded_chunks[coords] = chunk
	chunk.initialize(gameSave.get_chunk(coords), coords)

func unload_chunk(coords : Vector2i):
	#print("unloading chunk")
	# TODO: Save chunk
	LightManager.release_chunk(coords, loaded_chunks[coords].light_index)
	loaded_chunks[coords].queue_free()
	loaded_chunks.erase(coords)

func player_entered_chunk(chunk_coords : Vector2i):
	if loading_world:
		return
	var chunks_to_load = []
	var chunks_to_unload = []
	var new_set = []
	for y in range(-1,2): # inclusive start, exclusive end
		for x in range(-1,2):
			var coords = chunk_coords + Vector2i(x,y)
			if !loaded_chunks.has(coords):
				chunks_to_load.append(coords)
			new_set.append(coords)

	for old_chunk in loaded_chunks:
		if !new_set.has(old_chunk):
			chunks_to_unload.append(old_chunk)
	
	for c in chunks_to_load:
		await Engine.get_main_loop().process_frame
		load_chunk(c)
	for c in chunks_to_unload:
		await Engine.get_main_loop().process_frame
		unload_chunk(c)
			

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
		set_wall(coords, TileHandler.EMPTY_WALL)
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
	#var changed := false
	
	var tile_resource : TileResource
	if wall : tile_resource = get_wall(coords)
	else: tile_resource = get_tile(coords)
	
	if tile_resource == null:
		return
	
	if tile_resource.potential_supports.size() > 0:
		var support_found := false
		for support in tile_resource.potential_supports:
			if wall and !is_wall_empty(coords+support) or !wall and !is_tile_empty(coords+support):
				support_found = true
				break
		if !support_found:
			break_tile(coords, wall)
			#changed = true
	
	#if changed:
		#update_neighbors(coords, wall)

func set_tile(coords : Vector2i, tile_resource : TileResource):
	var chunk_coords = coords / GlobalReferences.CHUNK_SIZE
	var chunk = loaded_chunks[chunk_coords]
	chunk.set_tile(coords % GlobalReferences.CHUNK_SIZE, tile_resource)
	#tile_list[coords.x][coords.y] = tile_resource.id
	#tiles_tilemap.set_cell(0, coords, tile_dict[tile_resource.name][0], tile_dict[tile_resource.name][1])
	
	LightManager.update(coords)
	
	#gameSave.tiles[coords.x + coords.y*gameSave.width] = tile_resource.id

func set_wall(coords : Vector2i, tile_resource : TileResource):
	var chunk_coords = coords / GlobalReferences.CHUNK_SIZE
	var chunk = loaded_chunks[chunk_coords]
	chunk.set_wall(coords % GlobalReferences.CHUNK_SIZE, tile_resource)
	
	LightManager.update(coords)
	
	#gameSave.walls[coords.x + coords.y*gameSave.width] = tile_resource.id

func place_tile(coords : Vector2, item : TileItem):
	if coords.x < 0 or coords.y < 0 or coords.x >= gameSave.get_width() or coords.y >= gameSave.get_height():
		push_error("Trying to place tile out of bounds: ", item.name, " : ", coords)
		return
	
	var tile_resource = TileHandler.tiles[item.tile_id]
	
	if tile_resource.wall:
		set_wall(coords, tile_resource)
	else:
		set_tile(coords, tile_resource)

func place_multiblock(coords : Vector2, multiblock_item : MultiblockItem):
	var multiblock = multiblock_item.prefab.instantiate()
	multiblock.position = coords * GlobalReferences.TILE_SIZE
	multiblocks_root.add_child(multiblock)
	
	for i in multiblock_item.tile_ids.size():
		var tile_resource = TileHandler.tiles[multiblock_item.tile_ids[i]]
		@warning_ignore("integer_division")
		var offset = Vector2(i%multiblock_item.size.x, i/multiblock_item.size.x)
		set_tile(coords + offset, tile_resource)
	
	multiblock.setup(self, coords)


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

func save_game():
	pass#ResourceSaver.save(gameSave, "res://game saves/game_save_resource.tres")
