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
			var lambda = func():
				update(t)
			t.broke.connect(lambda)
			t.placed.connect(lambda)
			w.broke.connect(lambda)
			w.placed.connect(lambda)

	# complete an initial lighting pass
	for y in world_size.y:
		for x in world_size.x:
			calculate_light_level(Vector2(x,y))

func update(tile : Tile):
	var tiles = [] # The final list of tiles, ordered from the center outward
	var unchecked_tiles = [tile] # Queue of tiles which have not been dealt with yet
	var edge = [] # List of tiles surrounding "tiles"
	var center = tile.position/GlobalReferences.TILE_SIZE
	
	# Breadth first search of all tiles in range
	while unchecked_tiles.size() > 0:
		var t = unchecked_tiles[0]
		t.light_level = 0
		var coordinates = t.position / GlobalReferences.TILE_SIZE
		for offset in adjacents:
			# get a reference to the tile
			var adjacent_coordinates = Vector2(coordinates.x+offset.x, coordinates.y+offset.y)
			var adjacent_tile = game_world.get_tile(adjacent_coordinates.x, adjacent_coordinates.y)
			
			# don't worry about tiles that are too far away
			var diff = adjacent_coordinates - center
			if abs(diff.x) + abs(diff.y) > sky_light_level:
				if !edge.has(adjacent_tile):
					edge.append(adjacent_tile)
				continue
			
			# ignore if it's a null tile
			if adjacent_tile == null:
				continue
			
			# if we haven't seen this tile yet, add it to the queue
			if !tiles.has(adjacent_tile) and !unchecked_tiles.has(adjacent_tile):
				unchecked_tiles.append(adjacent_tile)
		
		tiles.append(t)
		unchecked_tiles.erase(t)
	
	# sort edge array based on light level (highest to lowest)
	edge.sort_custom(func(a,b): return a.light_level>b.light_level)
	
	# calculate the lighting for each tile, working outside-in
	while tiles.size() > 0:
		var t = edge[0]
		var coords = t.position / GlobalReferences.TILE_SIZE
		for offset in adjacents:
			var adjacent_tile = game_world.get_tile(coords.x+offset.x, coords.y+offset.y)
			if tiles.has(adjacent_tile):
				calculate_light_level(adjacent_tile.position/GlobalReferences.TILE_SIZE)
				tiles.erase(adjacent_tile)
				for i in edge.size():
					if edge[i].light_level <= adjacent_tile.light_level:
						edge.insert(i, adjacent_tile)
						break
				if !edge.has(adjacent_tile):
					edge.append(adjacent_tile)
		edge.erase(t)
	

func calculate_light_level(coords : Vector2):
	var t = game_world.get_tile(coords.x,coords.y)
	if game_world.get_wall(coords.x,coords.y).empty:
		t.light_level = sky_light_level
	else:
		var reduction = 2
		if t.empty:
			reduction = 1
		
		for offset in adjacents:
			var adjacent_tile = game_world.get_tile(coords.x+offset.x, coords.y+offset.y)
			if adjacent_tile == null:
				continue
			t.light_level = max(t.light_level, adjacent_tile.light_level-reduction)
	
	t.set_light_level(t.light_level)
	game_world.get_wall(coords.x,coords.y).set_light_level(t.light_level)
