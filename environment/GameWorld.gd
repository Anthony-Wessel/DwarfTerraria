class_name GameWorld
extends Node2D

static var instance : GameWorld

var gameSave : GameSave
@export var player : CharacterMovement

@export var multiblocks_root : Node2D

@export var tiles_tilemap : TileMap
var tile_dict : Dictionary

var tile_list = []
var walls_list = []

signal world_finished_loading

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
	var tile_set = tiles_tilemap.tile_set
	for source_index in tile_set.get_source_count():
		var source_id = tile_set.get_source_id(source_index)
		var source : TileSetAtlasSource = tile_set.get_source(source_id)
		if source == null:
			continue
		
		for tile_index in source.get_tiles_count():
			var coords := source.get_tile_id(tile_index)
			var tile_data = source.get_tile_data(coords, 0)
			var tile_name = tile_data.get_custom_data_by_layer_id(0)
			var tile_texture = source
			tile_dict[tile_name] = [source_id, coords]

func load_game():
	# Create new game save
	gameSave = GameSave.new()
	gameSave.width = 100
	gameSave.height = 100
	WorldGenerator.GenerateWorld(gameSave)
	
	# Load game save
	#gameSave = ResourceLoader.load("res://game saves/game_save_resource.tres")
	
	tile_list = []
	walls_list = []
	for x in gameSave.width:
		var tile_col = []
		var wall_col = []
		for y in gameSave.height:
			tile_col.append(gameSave.tiles[x + y*gameSave.width])
			wall_col.append(gameSave.walls[x + y*gameSave.width])
			
			var tile_resource = TileHandler.tiles[gameSave.tiles[x + y*gameSave.width]]
			tiles_tilemap.set_cell(0, Vector2i(x,y), tile_dict[tile_resource.name][0], tile_dict[tile_resource.name][1])
			
			var wall_resource = TileHandler.tiles[gameSave.walls[x + y*gameSave.width]]
			tiles_tilemap.set_cell(1, Vector2i(x,y), tile_dict[wall_resource.name][0], tile_dict[wall_resource.name][1])
			
		tile_list.append(tile_col)
		walls_list.append(wall_col)
	

	player.global_position = global_position + gameSave.player_spawn
	
	world_finished_loading.emit()

func is_tile_empty(coords : Vector2) -> bool:
	return tile_list[coords.x][coords.y] == 0

func is_wall_empty(coords : Vector2) -> bool:
	return walls_list[coords.x][coords.y] == 8

func get_player_spawn():
	return gameSave.player_spawn


func get_tile(coords : Vector2) -> TileResource:
	return TileHandler.tiles[ tile_list[coords.x][coords.y] ]

func get_wall(coords : Vector2) -> TileResource:
	return TileHandler.tiles[ walls_list[coords.x][coords.y] ]


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

func set_tile(coords : Vector2, tile_resource : TileResource):
	tile_list[coords.x][coords.y] = tile_resource.id
	tiles_tilemap.set_cell(0, coords, tile_dict[tile_resource.name][0], tile_dict[tile_resource.name][1])
	
	LightManager.update(coords)
	
	gameSave.tiles[coords.x + coords.y*gameSave.width] = tile_resource.id

func set_wall(coords : Vector2, tile_resource : TileResource):
	walls_list[coords.x][coords.y] = tile_resource.id
	tiles_tilemap.set_cell(1, coords, tile_dict[tile_resource.name][0], tile_dict[tile_resource.name][1])
	
	LightManager.update(coords)
	
	gameSave.walls[coords.x + coords.y*gameSave.width] = tile_resource.id

func place_tile(coords : Vector2, item : TileItem):
	if coords.x < 0 or coords.y < 0 or coords.x >= gameSave.width or coords.y >= gameSave.height:
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

func global_to_tile_coordinates(global_coords : Vector2):
	return (global_coords - global_position)/GlobalReferences.TILE_SIZE

func save_game():
	ResourceSaver.save(gameSave, "res://game saves/game_save_resource.tres")
