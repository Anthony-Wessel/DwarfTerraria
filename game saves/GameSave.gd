class_name GameSave
extends Resource

func get_width():
	return world_info.size.x * GlobalReferences.CHUNK_SIZE
func get_height():
	return world_info.size.y * GlobalReferences.CHUNK_SIZE

func get_chunk(coords: Vector2):
	if coords.x + coords.y*world_info.size.x >= 20:
		print(coords)
	return chunks[coords.x + coords.y*world_info.size.x]

func get_tile(coords : Vector2i, wall : bool):
	if wall:
		return TileHandler.tiles[get_value(coords, 1)]
	else:
		return TileHandler.tiles[get_value(coords, 0)]

func get_light_values(coords : Vector2i):
	return get_value(coords, 2)

func set_tile(coords : Vector2i, tile_id : int):
	set_value(coords, 0, tile_id)

func set_wall(coords : Vector2i, tile_id : int):
	set_value(coords, 1, tile_id)

func set_light_values(coords : Vector2i, values : Vector2):
	set_value(coords, 2, values)

func get_value(coords : Vector2i, value_index : int):
	var data_list = get_data_list(coords, value_index)
	var inner_coords = coords % GlobalReferences.CHUNK_SIZE
	return data_list[inner_coords.x + inner_coords.y * GlobalReferences.CHUNK_SIZE]

func set_value(coords : Vector2i, value_index : int, value):
	var data_list = get_data_list(coords, value_index)
	var inner_coords = coords % GlobalReferences.CHUNK_SIZE
	data_list[inner_coords.x + inner_coords.y*GlobalReferences.CHUNK_SIZE] = value

func get_data_list(coords : Vector2i, value_index : int):
	var chunk_coords = coords / GlobalReferences.CHUNK_SIZE
	if value_index == 0:
		return get_chunk(chunk_coords).tiles
	elif value_index == 1:
		return get_chunk(chunk_coords).walls
	elif value_index == 2:
		return get_chunk(chunk_coords).lights
	
	return null

func contains_coordinates(coords : Vector2):
	return coords.x >= 0 and coords.y >= 0 and coords.x < get_width() and coords.y < get_height()

var chunks : Array[ChunkSave]
var world_info : WorldInfo

static func create_new_world(name : String, size : Vector2i):
	var new_save = GameSave.new()
	new_save.world_info = WorldInfo.create(name, size)
	var folder_path = "res://game saves/" + name
	DirAccess.make_dir_absolute(folder_path)
	
	await WorldGenerator.GenerateWorld(new_save)
	
	new_save.save_all()
	return new_save

static func load_world(world_name : String):
	var loaded_save = GameSave.new()
	var folder_path = "res://game saves/" + world_name
	loaded_save.world_info = load(folder_path + "/world_info.tres")
	var size = loaded_save.world_info.size
	for y in size.y:
		for x in size.x:
			loaded_save.load_chunk(Vector2i(x,y))
	
	return loaded_save

func save_all():
	ResourceSaver.save(world_info, "res://game saves/" + world_info.name + "/world_info.tres")
	
	save_player()
	
	for x in world_info.size.x:
		for y in world_info.size.y:
			save_chunk(Vector2i(x,y), null)

func save_player():
	var player_info = PlayerSave.new()
	var counter = 0
	for slot in InventoryInterface.player_inventory.contents:
		if slot.item != null:
			player_info.inventory_contents[counter] = slot.contents
		counter +=1
	ResourceSaver.save(player_info, "res://game saves/" + world_info.name + "/player_info.tres")

func load_player() -> PlayerSave:
	return load("res://game saves/" + world_info.name + "/player_info.tres")

func load_chunk(chunk_coords : Vector2i):
	var chunk_string = str(chunk_coords.x) + "-" + str(chunk_coords.y)
	var file_path = "res://game saves/" + world_info.name + "/" + chunk_string + ".tres"
	chunks.append(load(file_path))

func save_chunk(chunk_coords : Vector2i, updated_chunk : Chunk):
	# update chunk values
	var chunk = get_chunk(chunk_coords)
	if updated_chunk != null:
		chunk.tiles = updated_chunk.tiles
		chunk.walls = updated_chunk.walls
		chunk.lights = updated_chunk.lights
		chunk.entity_data = updated_chunk.save_entities()
	
	# Save to file
	var chunk_string = str(chunk_coords.x) + "-" + str(chunk_coords.y)
	var filename = "res://game saves/" + world_info.name + "/" + chunk_string + ".tres"
	ResourceSaver.save(chunk, filename)
