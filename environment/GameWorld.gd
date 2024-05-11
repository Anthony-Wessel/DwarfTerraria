class_name GameWorld
extends Node2D

static var tile_scene = preload("res://environment/tile.tscn")
static var instance : GameWorld

var gameSave : GameSave

func _init():
	instance = self

func _ready():
	load_game()

func load_game():
	# Create new game save
	gameSave = GameSave.new()
	gameSave.width = 100
	gameSave.height = 75
	WorldGenerator.GenerateWorld(gameSave)
	
	# Load game save
	#gameSave = ResourceLoader.load("res://game saves/game_save_resource.tres")
	
	# Load tiles from game save
	for y in gameSave.height:
		for x in gameSave.width:
			var newTile = tile_scene.instantiate()
			add_child(newTile)
			newTile.position = Vector2i(x*8,y*8)
			var item = gameSave.tiles[x+y*gameSave.width]
			if item != null:
				set_tile(x,y, item, false)
	
	# Load multiblocks
	
	# Load entities from game save
	# Load player info from game save
	# Load flags from game save
	
func get_tile(x, y):
	if x < 0 or y < 0 or x >= gameSave.width or y >= gameSave.height:
		return null
	return (get_child((x+y*gameSave.width)) as Tile)

func mine_tile(x, y, mining_tier, amount):
	var tile = get_tile(x,y)
	if tile == null or tile.empty:
		return
	if tile.mine(mining_tier, amount):
		gameSave.tiles[x+y+gameSave.width] = null
		save_game()

func set_tile(x,y,item : TileItem, save := true):
	if x < 0 or y < 0 or x >= gameSave.width or y >= gameSave.height:
		return
	
	var selected_tile = get_tile(x,y)
	selected_tile.place(item.texture, true, item.mining_time, item.mining_tier)
	
	var spawn_item = func():
		PickupFactory.Instance.spawn_pickup(item, selected_tile.position+Vector2(4,4))
	selected_tile.broke.connect(spawn_item)
	
	if save:
		gameSave.tiles[x+y*gameSave.width] = item
		save_game()

func set_multiblock(x,y, multiblock_item : MultiblockItem, save := true):
	var multiblock = multiblock_item.prefab.instantiate() as Multiblock
	multiblock.position = Vector2(x*8, y*8)
	add_child(multiblock)
	
	for a in multiblock_item.size.x:
		for b in multiblock_item.size.y:
			var t = get_tile(x+a, y+b)
			t.place(null, false, 1, 0)
			t.broke.connect(multiblock.on_broken)
			multiblock.composite_tiles.append(t)
			var spawn_item = func():
				PickupFactory.Instance.spawn_pickup(multiblock_item, multiblock.position + (multiblock_item.size * 4))
			multiblock.destroyed.connect(spawn_item)

func global_to_tile_coordinates(global_coords : Vector2):
	return (global_coords - global_position)/8

func save_game():
	ResourceSaver.save(gameSave, "res://game saves/game_save_resource.tres")
