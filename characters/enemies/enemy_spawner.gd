extends Node

@export var enemies : Array[EnemyResource]
@export var attempt_frequency := 1.0
@export var max_enemies := 5

var last_attempt := 0.0

var cam_reference
var spawned_enemy : Node = null
var next_enemy_to_spawn = null

func _ready():
	cam_reference = get_viewport().get_camera_2d()
	next_enemy_to_spawn = choose_random_enemy()

func _process(_delta):
	if attempt_frequency == 0:
		return
	if get_children().size() > max_enemies:
		return
	
	# attempt a spawn (attempt_frequency) times per second
	if Time.get_ticks_msec()-last_attempt > 1000.0/attempt_frequency or spawned_enemy == null:
		attempt_spawn()
		last_attempt = Time.get_ticks_msec()
	
func _input(event):
	var mouse_event = event as InputEventMouseButton
	if mouse_event == null: return
#	
	if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		#attempt_spawn()
		next_enemy_to_spawn = enemies[2]

func choose_random_enemy():
	var rng = RandomNumberGenerator.new()
	var random_number = rng.randf()
	if random_number < 0.75:
		return enemies[0]
	elif random_number < 0.9:
		return enemies[1]
	else:
		return enemies[2]

func attempt_spawn():
	var rng = RandomNumberGenerator.new()
	var num = rng.randf()
	#if num > next_enemy_to_spawn.spawn_chance:
	#	return
	
	var pos = generate_spawn_position()
	var tile_coords : Vector2i  = GameWorld.instance.global_to_tile_coordinates(pos)
	
	# Only for zombie: if pos is in air drop it to ground
	if next_enemy_to_spawn.require_ground:
		var is_floor = !GameWorld.instance.is_tile_empty(tile_coords, false)
		var drop_height = 0
		while (!is_floor):
			tile_coords.y += 1
			is_floor = !GameWorld.instance.is_tile_empty(tile_coords, false)
			drop_height += 1
			if drop_height > 20:
				return
		pos.y += (drop_height-1)*GlobalReferences.TILE_SIZE
	
	var camera_rect : Rect2 = cam_reference.get_canvas_transform().affine_inverse()*get_viewport().get_visible_rect()
	#if camera_rect.has_point(pos):
		#return
	
	var offset = Vector2i(-floor(next_enemy_to_spawn.space_required.x/2), -1)
	for x in next_enemy_to_spawn.space_required.x:
		for y in next_enemy_to_spawn.space_required.y:
			var coords = tile_coords+offset + Vector2i(x,-y)
			if !GameWorld.instance.is_tile_empty(coords, false):
				return
	
	
	#print(pos, ", ", tile_coords, ", ", drop_height)
	spawned_enemy = next_enemy_to_spawn.prefab.instantiate()
	spawned_enemy.position = (tile_coords + Vector2i(0.5,-1)) * GlobalReferences.TILE_SIZE
	add_child(spawned_enemy)
	
	next_enemy_to_spawn = choose_random_enemy()
	
func generate_spawn_position():
	# get world coordinates of viewport
	var rect : Rect2 = cam_reference.get_canvas_transform().affine_inverse()*get_viewport().get_visible_rect()
	var x_max = GameWorld.instance.gameSave.get_width()
	var y_max= GameWorld.instance.gameSave.get_height()
	# get random offset
	var rng = RandomNumberGenerator.new()
	var x = rng.randf_range(max(0, rect.position.x-100), min(x_max, rect.position.x+rect.size.x+100))
	var y = rng.randf_range(max(0, rect.position.y-100), min(y_max, rect.position.y+rect.size.y+100))
	
	return Vector2(x,y)
