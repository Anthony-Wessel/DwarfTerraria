extends Node

var game_world : GameWorld

var world_size : Vector2

var sky_light_level := 15

var adjacents = [Vector2(0,1), Vector2(0,-1), Vector2(1,0), Vector2(-1,0)]

func initialize():
	game_world = GameWorld.instance
	world_size = Vector2(game_world.gameSave.width, game_world.gameSave.height)
	for x in world_size.x:
		for y in world_size.y:
			var t = game_world.get_tile(x,y)
			var w = game_world.get_wall(x,y)
			# connect signals
			var lambda_broke = func():
				update(t, false)
			var lambda_placed = func():
				update(t, true)
			t.broke.connect(lambda_broke)
			t.placed.connect(lambda_placed)
			w.broke.connect(lambda_broke)
			w.placed.connect(lambda_placed)

	# complete an initial lighting pass
	for y in world_size.y:
		for x in world_size.x:
			calculate_light_level(Vector2(x,y))

func update(tile : Tile, placed : bool):
	if placed and tile.light_source == 0:
		recalculate_dependents(tile)
	else:
		propagate_light(tile)
	
	
func propagate_light(tile : Tile):
	var tiles = [tile]
	while tiles.size() > 0:
		var coords = tiles[0].coordinates
		tiles.remove_at(0)
		if !calculate_light_level(coords):
			continue
		for offset in adjacents:
			var adjacent_coords = coords + offset
			var adjacent_tile = game_world.get_tile(adjacent_coords.x, adjacent_coords.y)
			tiles.append(adjacent_tile)
		

func recalculate_dependents(tile : Tile):
	var tiles = []
	var unchecked_tiles = [tile]
	while unchecked_tiles.size() > 0:
		var t = unchecked_tiles[0]
		for offset in adjacents:
			var adjacent_coords = t.coordinates + offset
			var adjacent_tile = game_world.get_tile(adjacent_coords.x, adjacent_coords.y)
			if adjacent_tile.light_parent == -offset:
				unchecked_tiles.append(adjacent_tile)
		
		t.set_light_level(0)
		unchecked_tiles.erase(t)
		tiles.append(t)
	
	for t in tiles:
		propagate_light(t)

func calculate_light_level(coords : Vector2) -> bool:
	var t = game_world.get_tile(coords.x,coords.y)
	var new_light_level = t.light_level
	if game_world.get_wall(coords.x,coords.y).empty:
		new_light_level = sky_light_level
		t.light_parent = Vector2(0,0)
	else:
		var reduction = 2
		if t.empty:
			reduction = 1
		
		for offset in adjacents:
			var adjacent_tile = game_world.get_tile(coords.x+offset.x, coords.y+offset.y)
			if adjacent_tile == null:
				continue
			if adjacent_tile.light_level-reduction > new_light_level:
				new_light_level = adjacent_tile.light_level-reduction
				t.light_parent = offset

	var updated = new_light_level != t.light_level	
	t.set_light_level(new_light_level)
	game_world.get_wall(coords.x,coords.y).set_light_level(new_light_level)
	
	return updated
