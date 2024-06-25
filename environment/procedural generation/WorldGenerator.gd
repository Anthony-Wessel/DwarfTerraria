class_name WorldGenerator
extends Node

static var rng := RandomNumberGenerator.new()

static var empty = 0
static var dirt = 1
static var grass = 2
static var stone = 3

static var copper = 33
static var iron = 34
static var mithril = 35

static var empty_wall = 8
static var dirt_wall = 9
static var stone_wall = 10

static var tree_base = 13
static var tree_trunk = 14
static var tree_trunk_left = 15
static var tree_trunk_right = 16
static var tree_branch_left = 17
static var tree_branch_right = 18
static var tree_top1 = 19
static var tree_top2 = 20
static var tree_top3 = 21
static var tree_top4 = 22
static var tree_top5 = 23
static var tree_top6 = 24

static func GenerateWorld(worldResource : GameSave):
	worldResource.chunks.clear()
	worldResource.world_seed = rng.randi()
	# Generate chunks (2 sky, 1 surface, 6 cave
	for y in worldResource.vertical_chunks:
		for x in worldResource.horizontal_chunks:
			if y <= 1:
				worldResource.chunks.append(generate_sky_chunk())
			elif y == 2:
				worldResource.chunks.append(generate_surface_chunk(Vector2(x,y)))
			else:
				worldResource.chunks.append(await generate_cave_chunk(Vector2(x,y), worldResource.world_seed))
	
	
	# Set player spawn
	@warning_ignore("integer_division")
	var mid_chunk : int = worldResource.horizontal_chunks / 2
	var chunk = worldResource.get_chunk(Vector2(mid_chunk, 2))
	@warning_ignore("integer_division")
	var t = chunk[0][GlobalReferences.CHUNK_SIZE/2] # 0 for tiles, then x value (y = 0)
	var spawn_y = 0
	while t != grass:
		spawn_y += 1
		@warning_ignore("integer_division")
		t = chunk[0][GlobalReferences.CHUNK_SIZE/2 + spawn_y * GlobalReferences.CHUNK_SIZE]
	
	var spawnX = (float(mid_chunk)+0.5)*GlobalReferences.CHUNK_SIZE
	var spawnY = GlobalReferences.CHUNK_SIZE * 2 + spawn_y-1
	worldResource.player_spawn = Vector2(spawnX, spawnY)
	
	# calculate lighting
	LightManager.preload_lighting(worldResource)
	
	#place_trees(worldResource)

static func place_trees(worldResource : GameSave):
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

static func generate_cave_texture(rng_seed : int, offset : Vector2) -> Texture2D:
	var cave_tex = await generate_cave_tex(rng_seed, offset)
	var refined_cave_tex = ShaderComputer.run_shader("res://environment/procedural generation/procedural_terrain.glsl", [cave_tex], 100, 100)
	
	var base_ore_tex = await generate_ore_tex(rng_seed, offset)
	var final_tex = ShaderComputer.run_shader("res://environment/procedural generation/procedural_ore.glsl", [refined_cave_tex, base_ore_tex], 100, 100)
	
	return final_tex

static func generate_cave_tex(rng_seed : int, offset : Vector2):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.frequency = 0.05
	noise.seed = rng_seed
	noise.offset = Vector3(offset.x, offset.y, 0.0) * GlobalReferences.CHUNK_SIZE
	
	var noise_tex = NoiseTexture2D.new()
	noise_tex.height = 100
	noise_tex.width = 100
	noise_tex.generate_mipmaps = false
	noise_tex.noise = noise
	
	await noise_tex.changed
	
	return noise_tex

static func generate_ore_tex(rng_seed : int, offset : Vector2):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.cellular_distance_function = FastNoiseLite.DISTANCE_HYBRID
	noise.cellular_jitter = 2.0
	noise.frequency = 0.2
	noise.seed = rng_seed
	noise.offset = Vector3(offset.x, offset.y, 0.0) * GlobalReferences.CHUNK_SIZE
	
	var tex = NoiseTexture2D.new()
	tex.width = 100
	tex.height = 100
	tex.generate_mipmaps = false
	tex.noise = noise
	
	await tex.changed
	
	return tex


static func generate_sky_chunk():
	var tiles = []
	var walls = []
	var lights = []
	
	for y in GlobalReferences.CHUNK_SIZE:
		for x in GlobalReferences.CHUNK_SIZE:
			tiles.append(empty)
			walls.append(empty_wall)
			lights.append(Vector2(0,30))
	
	return [tiles, walls, lights]

static func generate_surface_chunk(chunk_coords : Vector2):
	var tiles = []
	var walls = []
	var lights = []
	
	# Determine column heights
	var heights = []
	var increment = 0
	var remaining_tiles = 0
	for i in GlobalReferences.CHUNK_SIZE:
		if i == 0:
			heights.append(GlobalReferences.CHUNK_SIZE * 0.5)
			continue
		if remaining_tiles == 0:
			# start a new stretch
			if increment == 0:
				increment = sign(rng.randf()-0.5)
				remaining_tiles = rng.randi_range(1,5)
			else:
				increment = 0
				remaining_tiles = rng.randi_range(5,10)
		
		heights.append(min(max(0,heights[i-1] + increment), GlobalReferences.CHUNK_SIZE-1))
		remaining_tiles -= 1
	
	# Determine tiles based on height
	var columns = []
	for h in heights:
		var col = []
		
		for i in GlobalReferences.CHUNK_SIZE - h:
			col.append(empty)
		
		col.append(grass)
		
		for i in rng.randi_range(2,4):
			col.append(dirt)
		
		while col.size() < GlobalReferences.CHUNK_SIZE:
			col.append(stone)
		
		columns.append(col)
	
	# Set tiles and walls
	for y in GlobalReferences.CHUNK_SIZE:
		for x in GlobalReferences.CHUNK_SIZE:
			tiles.append(columns[x][y])
			lights.append(Vector2(0,0))
			
			if columns[x][y] == dirt:
				walls.append(dirt_wall)
			elif columns[x][y] == stone:
				walls.append(stone_wall)
			else:
				walls.append(empty_wall)
				lights[x + y*GlobalReferences.CHUNK_SIZE] = Vector2(0,30)
	
	return [tiles, walls, lights]

static func generate_cave_chunk(chunk_coords: Vector2, rng_seed : int):
	var tiles = []
	var walls = []
	var lights = []
	
	var cave_tex = await generate_cave_texture(rng_seed, chunk_coords)
	var img = cave_tex.get_image()
	for y in GlobalReferences.CHUNK_SIZE:
		for x in GlobalReferences.CHUNK_SIZE:
			var color : Color = img.get_pixel(x,y)
			if color.r == color.g and color.r == color.b:
				if color.r > 0.5:
					tiles.append(stone)
				else:
					tiles.append(empty)
			elif color.r > 0.5:
				tiles.append(copper)
			elif color.g > 0.5:
				tiles.append(iron)
			elif color.b > 0.5:
				tiles.append(mithril)
			
			walls.append(stone_wall)
			lights.append(Vector2(0,0))
	
	return [tiles, walls, lights]
