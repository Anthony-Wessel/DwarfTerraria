class_name WorldGenerator
extends Node

static func GenerateWorld(worldResource : GameSave):
	worldResource.tiles.clear()
	
	var dirt = preload("res://items/tiles/Idirt.tres")
	var grass = preload("res://items/tiles/Igrass.tres")
	var stone = preload("res://items/tiles/Istone.tres")
	
	var dirt_wall = preload("res://items/walls/Wdirt.tres")
	
	var rng := RandomNumberGenerator.new()
	
	# Determine surface height for each column
	var heights = []
	var increment = 0
	var remaining_tiles = 0
	for i in worldResource.width:
		if i == 0:
			heights.append(70)
			continue
		if remaining_tiles == 0:
			# start a new stretch
			if increment == 0:
				increment = sign(rng.randf()-0.5)
				remaining_tiles = rng.randi_range(1,5)
			else:
				increment = 0
				remaining_tiles = rng.randi_range(5,10)
		
		heights.append(heights[i-1] + increment)
		remaining_tiles -= 1
	
	var midpoint = worldResource.width / 2
	worldResource.player_spawn = GlobalReferences.TILE_SIZE*Vector2(midpoint, 100-heights[midpoint])
	
	var columns = []
	for h in heights:
		var col = []
		
		for i in worldResource.height - h:
			col.append(null)
		
		col.append(grass)
		
		for i in rng.randi_range(2,4):
			col.append(dirt)
		
		while col.size() < 100:
			col.append(stone)
		
		columns.append(col)
		
	
	
	
	for y in worldResource.height:
		for x in worldResource.width:
			worldResource.tiles.append(columns[x][y])
			if columns[x][y] == dirt:
				worldResource.walls.append(dirt_wall)
			else:
				worldResource.walls.append(null)
