extends Node

@export var enemies : Array[EnemyResource]
@export var attempt_frequency := 1

var last_attempt := 0.0

var cam_reference

func _ready():
	cam_reference = get_viewport().get_camera_2d()

func _process(_delta):
	# Every 1/attempt_frequency seconds 
	if Time.get_ticks_msec()-last_attempt > 1000.0/attempt_frequency:
		attempt_spawn()
		last_attempt = Time.get_ticks_msec()
	

func choose_random_enemy():
	var rng = RandomNumberGenerator.new()
	var enemy_index = rng.randi_range(0, enemies.size()-1)
	return enemies[enemy_index]

func attempt_spawn():
	var enemy_to_spawn = choose_random_enemy()
	var rng = RandomNumberGenerator.new()
	var num = rng.randf()
	if num > enemy_to_spawn.spawn_chance:
		return
	
	var pos = generate_spawn_position()
	
	var tile_coords : Vector2i  = GameWorld.instance.global_to_tile_coordinates(pos)
	
	var is_floor = !GameWorld.instance.is_tile_empty(tile_coords, false)
	if enemy_to_spawn.require_ground:
		var drop_height = 0
		while (!is_floor):
			tile_coords.y += 1
			is_floor = !GameWorld.instance.is_tile_empty(tile_coords, false)
			drop_height += 1
			if drop_height > 20:
				return
		pos.y += drop_height*GlobalReferences.TILE_SIZE
	
	var camera_rect : Rect2 = cam_reference.get_canvas_transform().affine_inverse()*get_viewport().get_visible_rect()
	if camera_rect.has_point(pos):
		return
	
	var offset = Vector2i(-floor(enemy_to_spawn.space_required.x/2), -1)
	for x in enemy_to_spawn.space_required.x:
		for y in enemy_to_spawn.space_required.y:
			var coords = tile_coords+offset + Vector2i(x,-y)
			if GameWorld.instance.is_tile_empty(coords, false):
				return
	
	
	#print(pos, ", ", tile_coords, ", ", drop_height)
	var spawned_enemy = enemy_to_spawn.prefab.instantiate()
	spawned_enemy.position = (tile_coords + Vector2i(0.5,-1)) * GlobalReferences.TILE_SIZE
	add_child(spawned_enemy)
	
func generate_spawn_position():
	# get world coordinates of viewport
	var rect : Rect2 = cam_reference.get_canvas_transform().affine_inverse()*get_viewport().get_visible_rect()
	var x_max = GameWorld.instance.gameSave.width
	var y_max= GameWorld.instance.gameSave.height
	# get random offset
	var rng = RandomNumberGenerator.new()
	var x = rng.randf_range(max(0, rect.position.x-100), min(x_max, rect.position.x+rect.size.x+100))
	var y = rng.randf_range(max(0, rect.position.y-100), min(y_max, rect.position.y+rect.size.y+100))
	
	return Vector2(x,y)
