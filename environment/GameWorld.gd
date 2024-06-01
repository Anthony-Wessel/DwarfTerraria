class_name GameWorld
extends Node2D

static var tile_scene = preload("res://environment/tile.tscn")
static var instance : GameWorld

var gameSave : GameSave
@export var player : CharacterMovement

@export var walls_root : Node2D
@export var tiles_root : Node2D

var tiles : Dictionary
var walls : Dictionary

signal world_finished_loading

func _init():
	instance = self

func _ready():
	load_game()

func load_game():
	# Create new game save
	gameSave = GameSave.new()
	gameSave.width = 100
	gameSave.height = 100
	WorldGenerator.GenerateWorld(gameSave)
	# Load game save
	#gameSave = ResourceLoader.load("res://game saves/game_save_resource.tres")
	
	# instantiate tiles
	for y in gameSave.height:
		for x in gameSave.width:
			var coordinates := Vector2(x,y)
			# load wall
			var newWall = tile_scene.instantiate()
			walls_root.add_child(newWall)
			walls[coordinates] = newWall
			newWall.set_coordinates(Vector2(x,y))
			
			# load tile
			var newTile = tile_scene.instantiate()
			tiles_root.add_child(newTile)
			tiles[coordinates] = newTile
			newTile.set_coordinates(Vector2(x,y))

	
	# load tiles
	for y in gameSave.height:
		for x in gameSave.width:
			
			var wallItem = gameSave.walls[x+y*gameSave.width]
			if wallItem != null:
				set_tile(x,y, wallItem, false)
			
			var item = gameSave.tiles[x+y*gameSave.width]
			if item != null:
				set_tile(x,y, item, false)
			
	# Load multiblocks
	
	# Load entities from game save
	# Load player info from game save
	player.global_position = global_position + gameSave.player_spawn
	# Load flags from game save
	
	world_finished_loading.emit()

func get_player_spawn():
	return gameSave.player_spawn

func get_tile(coords : Vector2) -> Tile:
	if tiles.has(coords):
		return tiles[coords] as Tile
	else:
		return null

func get_wall(coords : Vector2) -> Tile:
	if walls.has(coords):
		return walls[coords] as Tile
	else:
		return null

func mine_tile(coords_list : Array[Vector2i], mining_tier, amount : float, wall : bool):
	var tiles = []
	for coords in coords_list:
		if wall:
			var w = get_wall(coords)
			if w != null and !w.empty:
				tiles.append(w)
		else:
			var t = get_tile(coords)
			if t != null and !t.empty:
				tiles.append(t)
	
	var changed := false
	for tile in tiles:
		if tile.mine(mining_tier, amount/tiles.size()):
			gameSave.tiles[tile.coordinates.x + tile.coordinates.y*gameSave.width] = null
			changed = true
	
	if changed:
		save_game()

func set_tile(x,y,item : TileItem, save := true):
	if x < 0 or y < 0 or x >= gameSave.width or y >= gameSave.height:
		return
	
	var selected_tile
	if item.is_wall:
		selected_tile = get_wall(Vector2(x,y))
	else:
		selected_tile = get_tile(Vector2(x,y))
	
	selected_tile.place(item.texture, item.collision_enabled, item.mining_time, item.mining_tier, item.light_source)
	
	if item.dropped_item != null:
		selected_tile.item_drop = item.dropped_item
	else:
		selected_tile.item_drop = item
	
	if item.required_support != Vector2.ZERO:
		var t : Tile
		var support_coords = Vector2(x,y) + item.required_support
		#print(support_coords, ", ", Vector2(x,y))
		if item.is_wall:
			t = get_wall(support_coords)
		else:
			t = get_tile(support_coords)
		t.add_dependent(selected_tile)
		
	
	if save:
		gameSave.tiles[x+y*gameSave.width] = item
		save_game()

func set_multiblock(x,y, multiblock_item : MultiblockItem, save := true):
	var multiblock = multiblock_item.prefab.instantiate() as Multiblock
	multiblock.position = Vector2(x*GlobalReferences.TILE_SIZE, y*GlobalReferences.TILE_SIZE)
	add_child(multiblock)
	
	for a in multiblock_item.size.x:
		for b in multiblock_item.size.y:
			var t = get_tile(Vector2(x+a, y+b))
			t.place(null, false, 1, 0, 0)
			t.broke.connect(multiblock.on_broken)
			multiblock.composite_tiles.append(t)
	
	var spawn_item = func():
		PickupFactory.Instance.spawn_pickup(multiblock_item, multiblock.position + (multiblock_item.size * GlobalReferences.TILE_SIZE/2))
	multiblock.destroyed.connect(spawn_item)

func global_to_tile_coordinates(global_coords : Vector2):
	return (global_coords - global_position)/GlobalReferences.TILE_SIZE

func save_game():
	ResourceSaver.save(gameSave, "res://game saves/game_save_resource.tres")
