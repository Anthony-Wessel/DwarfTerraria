class_name WorldGenerator
extends Node

static var rng := RandomNumberGenerator.new()

static func GenerateWorld(worldResource : GameSave):
	worldResource.tiles.clear()
	
	var empty = 0
	var dirt = 1
	var grass = 2
	var stone = 3
	
	var copper = 33
	var iron = 34
	var mithril = 35
	
	var empty_wall = 8
	var dirt_wall = 9
	var stone_wall = 10
	
	var tree_base = 13
	var tree_trunk = 14
	var tree_trunk_left = 15
	var tree_trunk_right = 16
	var tree_branch_left = 17
	var tree_branch_right = 18
	var tree_top1 = 19
	var tree_top2 = 20
	var tree_top3 = 21
	var tree_top4 = 22
	var tree_top5 = 23
	var tree_top6 = 24
	
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
	
	# Set player spawn
	@warning_ignore("integer_division")
	var midpoint : int = worldResource.width / 2
	worldResource.player_spawn = GlobalReferences.TILE_SIZE*Vector2(midpoint, worldResource.height-heights[midpoint])
	
	# set tiles based on heights
	var columns = []
	for h in heights:
		var col = []
		
		for i in worldResource.height - h:
			col.append(empty)
		
		col.append(grass)
		
		for i in rng.randi_range(2,4):
			col.append(dirt)
		
		while col.size() < worldResource.height:
			col.append(stone)
		
		columns.append(col)
		
	
	
	# Place tiles and walls
	for y in worldResource.height:
		for x in worldResource.width:
			worldResource.tiles.append(columns[x][y])
			
			if columns[x][y] == dirt:
				worldResource.walls.append(dirt_wall)
			elif columns[x][y] == stone:
				worldResource.walls.append(stone_wall)
			else:
				worldResource.walls.append(empty_wall)
	
	var cave_tex = await generate_cave_texture(rng.randi(), Vector2.ZERO)
	var img = cave_tex.get_image()
	for y in worldResource.height:
		for x in worldResource.width:
			if worldResource.tiles[x+ y*worldResource.width] == empty:
				continue
			var color : Color = img.get_pixel(x,y)
			if color.r == color.g and color.r == color.b:
				if color.r > 0.5:
					continue
				else:
					worldResource.tiles[x+ y*worldResource.width] = empty
			elif color.r > 0.5:
				worldResource.tiles[x+ y*worldResource.width] = copper
			elif color.g > 0.5:
				worldResource.tiles[x+ y*worldResource.width] = iron
			elif color.b > 0.5:
				worldResource.tiles[x+ y*worldResource.width] = mithril
				
				
	
	
	# Place trees
	var just_placed = false
	for x in range(1, worldResource.width-1):
		if rng.randf() < 0.8 or just_placed:
			just_placed = false
			continue
		
		just_placed = true
		
		# find the highest solid tile
		var tile = worldResource.tiles[x]
		var y = 0
		while tile == empty and y < worldResource.height-5:
			y += 1
			tile = worldResource.tiles[x+ y*worldResource.width]
		if y >= worldResource.height - 5:
			continue
		
		# place the tree
		worldResource.tiles[x + (y-1)*worldResource.width] = tree_base
		var y2 = y-1
		for i in rng.randi_range(3,10):
			y2 -= 1 
			var r = rng.randf()
			if r < 0.1 and worldResource.tiles[x-1 + y2*worldResource.width] == empty:
				worldResource.tiles[x + y2*worldResource.width] = tree_trunk_left
				worldResource.tiles[x-1 + y2*worldResource.width] = tree_branch_left
			elif r > 0.9 and worldResource.tiles[x+1 + y2*worldResource.width] == empty:
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
		
static func generate_cave_texture(seed : int, offset : Vector2) -> Texture2D:
	var cave_tex = await generate_cave_tex(seed, offset)
	var refined_cave_tex = ShaderComputer.run_shader("res://environment/procedural_terrain.glsl", [cave_tex], 100, 100)
	
	var base_ore_tex = await generate_ore_tex(seed, offset)
	var final_tex = ShaderComputer.run_shader("res://environment/procedural_ore.glsl", [refined_cave_tex, base_ore_tex], 100, 100)
	
	return final_tex
	

static func generate_cave_tex(seed : int, offset : Vector2):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.frequency = 0.05
	noise.seed = seed
	noise.offset = Vector3(offset.x, offset.y, 0.0) * GlobalReferences.CHUNK_SIZE
	
	var noise_tex = NoiseTexture2D.new()
	noise_tex.height = 100
	noise_tex.width = 100
	noise_tex.generate_mipmaps = false
	noise_tex.noise = noise
	
	await noise_tex.changed
	
	return noise_tex

static func generate_ore_tex(seed : int, offset : Vector2):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.cellular_distance_function = FastNoiseLite.DISTANCE_HYBRID
	noise.cellular_jitter = 2.0
	noise.frequency = 0.2
	noise.seed = seed
	noise.offset = Vector3(offset.x, offset.y, 0.0) * GlobalReferences.CHUNK_SIZE
	
	var tex = NoiseTexture2D.new()
	tex.width = 100
	tex.height = 100
	tex.generate_mipmaps = false
	tex.noise = noise
	
	await tex.changed
	
	return tex
