class_name WorldGenerator
extends Node

static func GenerateWorld(worldResource : GameSave):
	worldResource.tiles.clear()
	
	var dirt = preload("res://items/tiles/Idirt.tres")
	var grass = preload("res://items/tiles/Igrass.tres")
	var stone = preload("res://items/tiles/Istone.tres")
	
	var dirt_wall = preload("res://items/walls/Wdirt.tres")
	var stone_wall = preload("res://items/walls/Wstone.tres")
	
	var tree_base = preload("res://items/tiles/tree/Itree_base.tres")
	var tree_trunk = preload("res://items/tiles/tree/Itree_trunk.tres")
	var tree_trunk_left = preload("res://items/tiles/tree/Itree_trunk_left.tres")
	var tree_trunk_right = preload("res://items/tiles/tree/Itree_trunk_right.tres")
	var tree_branch_left = preload("res://items/tiles/tree/Itree_branch_left.tres")
	var tree_branch_right = preload("res://items/tiles/tree/Itree_branch_right.tres")
	var tree_top1 = preload("res://items/tiles/tree/Itree_top1.tres")
	var tree_top2 = preload("res://items/tiles/tree/Itree_top2.tres")
	var tree_top3 = preload("res://items/tiles/tree/Itree_top3.tres")
	var tree_top4 = preload("res://items/tiles/tree/Itree_top4.tres")
	var tree_top5 = preload("res://items/tiles/tree/Itree_top5.tres")
	var tree_top6 = preload("res://items/tiles/tree/Itree_top6.tres")
	
	
	var rng := RandomNumberGenerator.new()
	
	# Determine surface height for each column
	var heights = []
	var increment = 0
	var remaining_tiles = 0
	for i in worldResource.width:
		if i == 0:
			heights.append(worldResource.height*0.7)
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
	worldResource.player_spawn = GlobalReferences.TILE_SIZE*Vector2(midpoint, worldResource.height-heights[midpoint])
	
	var columns = []
	for h in heights:
		var col = []
		
		for i in worldResource.height - h:
			col.append(null)
		
		col.append(grass)
		
		for i in rng.randi_range(2,4):
			col.append(dirt)
		
		while col.size() < worldResource.height:
			col.append(stone)
		
		columns.append(col)
		
	
	
	
	for y in worldResource.height:
		for x in worldResource.width:
			worldResource.tiles.append(columns[x][y])
			
			if columns[x][y] == dirt:
				worldResource.walls.append(dirt_wall)
			elif columns[x][y] == stone:
				worldResource.walls.append(stone_wall)
			else:
				worldResource.walls.append(null)
	
	var just_placed = false
	for x in range(1, worldResource.width-1):
		if rng.randf() < 0.8 or just_placed:
			just_placed = false
			continue
		
		just_placed = true
		
		# find the highest solid tile
		var tile = worldResource.tiles[x]
		var y = 0
		while tile == null:
			y += 1
			tile = worldResource.tiles[x+ y*worldResource.width]
			
		
		# place the tree
		worldResource.tiles[x + (y-1)*worldResource.width] = tree_base
		var y2 = y-1
		for i in rng.randi_range(3,10):
			y2 -= 1 
			var r = rng.randf()
			if r < 0.1 and worldResource.tiles[x-1 + y2*worldResource.width] == null:
				worldResource.tiles[x + y2*worldResource.width] = tree_trunk_left
				worldResource.tiles[x-1 + y2*worldResource.width] = tree_branch_left
			elif r > 0.9 and worldResource.tiles[x+1 + y2*worldResource.width] == null:
				worldResource.tiles[x + y2*worldResource.width] = tree_trunk_right
				worldResource.tiles[x+1 + y2*worldResource.width] = tree_branch_right
			else:
				worldResource.tiles[x + y2*worldResource.width] = tree_trunk
		
		worldResource.tiles[x + (y2-1)*worldResource.width] = tree_top5
		worldResource.tiles[x-1 + (y2-1)*worldResource.width] = tree_top4
		worldResource.tiles[x+1 + (y2-1)*worldResource.width] = tree_top6
		worldResource.tiles[x + (y2-2)*worldResource.width] = tree_top2
		worldResource.tiles[x-1 + (y2-2)*worldResource.width] = tree_top1
		worldResource.tiles[x+1 + (y2-2)*worldResource.width] = tree_top3
		
		
		
