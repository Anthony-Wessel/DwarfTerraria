class_name GameWorld
extends Node2D

static var tile_scene = preload("res://environment/tile.tscn")

var gameSave : GameSave

func _init():
	GlobalReferences.gameWorld = self

func _ready():
	load_game()

func load_game():
	# Create new game save
	#gameSave = GameSave.new()
	#gameSave.width = 100
	#gameSave.height = 75
	#WorldGenerator.GenerateWorld(gameSave)
	
	# Load game save
	gameSave = ResourceLoader.load("res://game saves/game_save_resource.tres")
	
	# Load tiles from game save
	for y in gameSave.height:
		for x in gameSave.width:
			var newTile = tile_scene.instantiate()
			add_child(newTile)
			newTile.position = Vector2i(x*8,y*8)
			(newTile as Tile).item = gameSave.tiles[x+y*gameSave.width]
	
	# Load entities from game save
	# Load player info from game save
	# Load flags from game save
	
func get_tile(x, y):
	return (get_child((x+y*gameSave.width)) as Tile)

func set_tile(x,y,item : TileItem):
	if x < 0 or y < 0 or x >= gameSave.width or y >= gameSave.height:
		return
	
	var selected_tile = get_tile(x,y)
	
	if item == null and selected_tile.item != null:
		PickupFactory.Instance.spawn_pickup(selected_tile.item, selected_tile.position)
	
	selected_tile.item = item
	gameSave.tiles[x+y*gameSave.width] = item
	save_game()

func save_game():
	ResourceSaver.save(gameSave, "res://game saves/game_save_resource.tres")
