class_name GameWorld
extends Node2D

static var tile_scene = preload("res://environment/tile.tscn")
static var instance : GameWorld

var gameSave : GameSave
@export var player : CharacterMovement

@export var walls_root : Node2D
@export var tiles_root : Node2D

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
	
	# Load walls and tiles
	for y in gameSave.height:
		for x in gameSave.width:
			# load wall
			var newWall = tile_scene.instantiate()
			walls_root.add_child(newWall)
			newWall.set_coordinates(Vector2(x,y))
			var wallItem = gameSave.walls[x+y*gameSave.width]
			if wallItem != null:
				set_tile(x,y, wallItem, false)
			
			# load tile
			var newTile = tile_scene.instantiate()
			tiles_root.add_child(newTile)
			newTile.set_coordinates(Vector2(x,y))
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

func get_tile(x, y):
	if x < 0 or y < 0 or x >= gameSave.width or y >= gameSave.height:
		return null
	return (tiles_root.get_child((x+y*gameSave.width)) as Tile)

func get_wall(x, y):
	if x < 0 or y < 0 or x >= gameSave.width or y >= gameSave.height:
		return null
	return (walls_root.get_child((x+y*gameSave.width)) as Tile)

func mine_tile(x, y, mining_tier, amount, wall : bool):
	var tile
	if wall:
		tile = get_wall(x,y)
	else:
		tile = get_tile(x,y)
	
	if tile == null or tile.empty:
		return
	if tile.mine(mining_tier, amount):
		gameSave.tiles[x+y+gameSave.width] = null
		save_game()

func set_tile(x,y,item : TileItem, save := true):
	if x < 0 or y < 0 or x >= gameSave.width or y >= gameSave.height:
		return
	
	var selected_tile
	if item.is_wall:
		selected_tile = get_wall(x,y)
	else:
		selected_tile = get_tile(x,y)
	
	selected_tile.place(item.texture, !item.is_wall, item.mining_time, item.mining_tier)
	
	selected_tile.item_drop = item
	
	if save:
		gameSave.tiles[x+y*gameSave.width] = item
		save_game()

func set_multiblock(x,y, multiblock_item : MultiblockItem, save := true):
	var multiblock = multiblock_item.prefab.instantiate() as Multiblock
	multiblock.position = Vector2(x*GlobalReferences.TILE_SIZE, y*GlobalReferences.TILE_SIZE)
	add_child(multiblock)
	
	for a in multiblock_item.size.x:
		for b in multiblock_item.size.y:
			var t = get_tile(x+a, y+b)
			t.place(null, false, 1, 0)
			t.broke.connect(multiblock.on_broken)
			multiblock.composite_tiles.append(t)
	
	var spawn_item = func():
		PickupFactory.Instance.spawn_pickup(multiblock_item, multiblock.position + (multiblock_item.size * GlobalReferences.TILE_SIZE/2))
	multiblock.destroyed.connect(spawn_item)

func global_to_tile_coordinates(global_coords : Vector2):
	return (global_coords - global_position)/GlobalReferences.TILE_SIZE

func save_game():
	ResourceSaver.save(gameSave, "res://game saves/game_save_resource.tres")
