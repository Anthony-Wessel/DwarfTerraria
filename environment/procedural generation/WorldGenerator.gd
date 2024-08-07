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
	worldResource.world_info.name = "Test World"
	worldResource.world_info.world_seed = rng.randi()
	# Generate chunks (2 sky, 1 surface, 6 cave
	for y in worldResource.world_info.size.y:
		for x in worldResource.world_info.size.x:
			var new_chunk
			if y <= 1:
				new_chunk = generate_sky_chunk()
			elif y == 2:
				new_chunk = await generate_surface_chunk(Vector2(x,y), worldResource.world_info.world_seed)
			else:
				new_chunk = await generate_cave_chunk(Vector2(x,y), worldResource.world_info.world_seed)
			worldResource.chunks.append(ChunkSave.create(new_chunk[0], new_chunk[1], new_chunk[2]))
	
	# Set player spawn
	@warning_ignore("integer_division")
	var mid_chunk : int = worldResource.world_info.size.x / 2
	var chunk = worldResource.get_chunk(Vector2(mid_chunk, 2))
	@warning_ignore("integer_division")
	var t = chunk.tiles[GlobalReferences.CHUNK_SIZE/2] # (y = 0)
	var spawn_y = 0
	while t != grass:
		spawn_y += 1
		@warning_ignore("integer_division")
		t = chunk.tiles[GlobalReferences.CHUNK_SIZE/2 + spawn_y * GlobalReferences.CHUNK_SIZE]
	
	var spawnX = (float(mid_chunk)+0.5)*GlobalReferences.CHUNK_SIZE
	var spawnY = GlobalReferences.CHUNK_SIZE * 2 + spawn_y-1
	worldResource.world_info.player_spawn = Vector2(spawnX, spawnY)
	
	
	place_caves(worldResource)
	place_trees(worldResource)
	
	
	# calculate lighting
	LightManager.preload_lighting(worldResource)
	
############################
# Initial chunk generation #
############################
static func generate_cave_texture(rng_seed : int, offset : Vector2) -> Texture2D:
	var cave_tex = await generate_cave_tex(rng_seed, offset)
	var refined_cave_tex = ShaderComputer.run_shader("res://environment/procedural generation/procedural_terrain.glsl", [cave_tex], GlobalReferences.CHUNK_SIZE, GlobalReferences.CHUNK_SIZE)
	
	var base_ore_tex = await generate_ore_tex(rng_seed, offset)
	var final_tex = ShaderComputer.run_shader("res://environment/procedural generation/procedural_ore.glsl", [refined_cave_tex, base_ore_tex], GlobalReferences.CHUNK_SIZE, GlobalReferences.CHUNK_SIZE)
	
	return final_tex

static func generate_cave_tex(rng_seed : int, offset : Vector2):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.frequency = 0.05
	noise.seed = rng_seed
	noise.offset = Vector3(offset.x, offset.y, 0.0) * GlobalReferences.CHUNK_SIZE
	
	var noise_tex = NoiseTexture2D.new()
	noise_tex.height = GlobalReferences.CHUNK_SIZE
	noise_tex.width = GlobalReferences.CHUNK_SIZE
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
	tex.width = GlobalReferences.CHUNK_SIZE
	tex.height = GlobalReferences.CHUNK_SIZE
	tex.generate_mipmaps = false
	tex.noise = noise
	
	await tex.changed
	
	return tex

static func generate_surface_tex(rng_seed : int, offset : Vector2):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.frequency = 0.02
	noise.seed = rng_seed
	noise.offset = Vector3(offset.x, offset.y, 0.0) * GlobalReferences.CHUNK_SIZE
	
	return ImageTexture.create_from_image(noise.get_image(GlobalReferences.CHUNK_SIZE,GlobalReferences.CHUNK_SIZE,false,false,false))

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

static func generate_surface_chunk(chunk_coords : Vector2, rng_seed : int):
	var tiles = []
	var walls = []
	var lights = []
	
	var surface_tex = generate_surface_tex(rng_seed, chunk_coords)
	var img = surface_tex.get_image()
	
	# Determine column heights
	var heights = []
	for x in GlobalReferences.CHUNK_SIZE:
		var color := img.get_pixel(x,0)
		@warning_ignore("integer_division")
		heights.append(color.r * (GlobalReferences.CHUNK_SIZE/2)+15)
	
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
			else:
				tiles.append(stone)
			
			walls.append(stone_wall)
			lights.append(Vector2(0,0))
	
	return [tiles, walls, lights]

###################
# Surface Editing #
###################
static func place_trees(worldResource : GameSave):
	var just_placed = false
	for x in range(1, worldResource.get_width()-1):
		if rng.randf() < 0.8 or just_placed:
			just_placed = false
			continue
		
		just_placed = true
		
		# find the highest solid tile
		var tile = worldResource.get_tile(Vector2i(x, 2*GlobalReferences.CHUNK_SIZE), false)
		var y = 2*GlobalReferences.CHUNK_SIZE
		while tile.id != grass and y < (3*GlobalReferences.CHUNK_SIZE) - 1:
			y += 1
			tile = worldResource.get_tile(Vector2i(x, y), false)
		if y >= (3*GlobalReferences.CHUNK_SIZE) - 1:
			continue
		
		# place the tree
		worldResource.set_tile(Vector2i(x, y-1), tree_base)
		var y2 = y-1
		for i in rng.randi_range(3,10):
			y2 -= 1 
			var r = rng.randf()
			if r < 0.1 and worldResource.get_tile(Vector2i(x-1, y2), false).id == empty:
				worldResource.set_tile(Vector2i(x, y2), tree_trunk_left)
				worldResource.set_tile(Vector2i(x-1, y2), tree_branch_left)
			elif r > 0.9 and worldResource.get_tile(Vector2i(x+1, y2), false).id == empty:
				worldResource.set_tile(Vector2i(x, y2), tree_trunk_right)
				worldResource.set_tile(Vector2i(x+1, y2), tree_branch_right)
			else:
				worldResource.set_tile(Vector2i(x, y2), tree_trunk)
		
		worldResource.set_tile(Vector2i(x, y2-1), tree_top5)
		worldResource.set_tile(Vector2i(x-1, y2-1), tree_top4)
		worldResource.set_tile(Vector2i(x+1, y2-1), tree_top6)
		worldResource.set_tile(Vector2i(x, y2-2), tree_top2)
		worldResource.set_tile(Vector2i(x-1, y2-2), tree_top1)
		worldResource.set_tile(Vector2i(x+1, y2-2), tree_top3)

static func place_caves(worldResource : GameSave):
	@warning_ignore("integer_division")
	var mid_chunk : int = worldResource.world_info.size.x / 2
	var cooldown = 0
	for x in worldResource.world_info.size.x:
		if cooldown > 0:
			cooldown -= 1
			continue
		if x == mid_chunk:
			continue
		
		if rng.randf() > 0.2:
			dig_cave(worldResource, Vector2(x,2), Vector2(sign(rng.randf()-0.5),0))
			cooldown = 2

static func dig_cave(worldResource : GameSave, chunk_coords : Vector2, direction : Vector2):
	# Find the starting point for the cave on the surface
	var surface_center = (chunk_coords + Vector2(0.5, 0)) * GlobalReferences.CHUNK_SIZE
	var counter = 0
	while worldResource.get_tile(surface_center, false) == TileHandler.EMPTY_TILE and counter < GlobalReferences.CHUNK_SIZE:
		surface_center += Vector2(0,1)
		counter += 1
	
	surface_center += Vector2(0,-3)
	
	var depth = 40
	var offset = Vector2(0,0)
	for i in depth:
		var horizontal = rng.randi_range(0,4)-2
		if horizontal < 0: horizontal = 0
		for x in horizontal:
			erase_tiles_x(worldResource, surface_center + offset, 5)
			offset += direction
			
		erase_tiles_x(worldResource, surface_center + offset, 5)
		offset += Vector2(0,1)
	
	erase_tiles_circle(worldResource, surface_center + offset, 5)
	

static func erase_tiles_x(worldResource:  GameSave, center : Vector2, radius : int):
	for i in radius:
		worldResource.set_tile(center + i*Vector2(0,1), empty)
		worldResource.set_tile(center + i*Vector2(0,-1), empty)
		worldResource.set_tile(center + i*Vector2(1,0), empty)
		worldResource.set_tile(center + i*Vector2(-1,0), empty)

static func erase_tiles_circle(worldResource : GameSave, center : Vector2, radius : int):
	for x in range(2*radius+1):
		for y in range(2*radius+1):
			var offset = Vector2(x,y) - Vector2.ONE * radius
			if offset.length() < radius:
				worldResource.set_tile(center+offset, empty)
