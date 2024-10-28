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


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()


func _init():
	instance = self

func _ready():
	get_tree().set_auto_accept_quit(false)
	generate_tile_dict()
	load_game()

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
	var world_size = Vector2i(5,4)
	gameSave = await GameSave.create_new_world("Test World", world_size)
	
	# Load game save
	#gameSave = GameSave.load_world("Test World")

	
	var player_spawn = gameSave.world_info.player_spawn
	
	for y in world_size.y: # inclusive start, exclusive end
		for x in world_size.x:
			var coords = Vector2i(x,y)
			load_chunk(coords)
	
	player.global_position = player_spawn * GlobalReferences.TILE_SIZE
	
	var player_save = gameSave.load_player()
	if player_save != null:
		InventoryInterface.load_player_inventory(player_save)
	
	loading_world = false
	world_finished_loading.emit()
	print("World done loading")

func load_chunk(coords : Vector2i):
	if loaded_chunks.has(coords):
		push_error("Trying to load chunk that already exists")
		return
	var chunk : Chunk = chunk_prefab.instantiate()
	chunk.position = coords * GlobalReferences.CHUNK_SIZE * GlobalReferences.TILE_SIZE
	chunk.initialize(gameSave.get_chunk(coords), coords)
	
	loaded_chunks[coords] = chunk
	add_child.call_deferred(chunk)

func is_tile_empty(coords : Vector2i, wall : bool) -> bool:
	if wall:
		return get_tile(coords, wall) == TileHandler.EMPTY_WALL
	else:
		return get_tile(coords, wall) == TileHandler.EMPTY_TILE

func get_player_spawn():
	return gameSave.world_info.player_spawn


func get_tile(coords : Vector2i, wall : bool) -> TileResource:
	var chunk_coords : Vector2i = coords / GlobalReferences.CHUNK_SIZE
	if loaded_chunks.has(chunk_coords):
		var id = loaded_chunks[chunk_coords].get_tile(coords % GlobalReferences.CHUNK_SIZE, wall)
		return TileHandler.tiles[id]
	
	return null

func break_tile(coords : Vector2, wall : bool):
	var tile_resource = get_tile(coords, wall)
	if wall:
		set_tile(coords, TileHandler.EMPTY_WALL)
	else:
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
	var tile_resource := get_tile(coords, wall)
	
	if tile_resource == null:
		return
	
	if tile_resource.potential_supports.size() > 0:
		var support_found := false
		for support in tile_resource.potential_supports:
			var support_resource = get_tile(coords+support, wall)
			
			if support_resource != null\
			and support_resource != TileHandler.EMPTY_WALL\
			and support_resource != TileHandler.EMPTY_TILE:
				support_found = true
				break
		
		if !support_found:
			break_tile(coords, wall)

func set_tile(coords : Vector2i, tile_resource : TileResource):
	var chunk_coords = coords / GlobalReferences.CHUNK_SIZE
	var chunk = loaded_chunks[chunk_coords]
	chunk.set_tile(coords % GlobalReferences.CHUNK_SIZE, tile_resource)
	
	LightManager.update(coords)

func place_item(coords : Vector2, item : PlaceableItem):
	var is_wall = TileHandler.tiles[item.tile_ids[0]].wall
	for x in item.size.x:
		for y in item.size.y:
			if !is_tile_empty(coords+Vector2(x,y), is_wall):
				return false
	
	for i in item.tile_ids.size():
		var tile_resource = TileHandler.tiles[item.tile_ids[i]]
		@warning_ignore("integer_division")
		var offset = Vector2(i%item.size.x, i/item.size.x)
		
		set_tile(coords+offset, tile_resource)
	
	return true

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
