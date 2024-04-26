extends Node

@export var enemy_scene : PackedScene
@export var attempt_frequency := 1

var last_attempt := 0.0

var cam_reference

func _ready():
	cam_reference = get_viewport().get_camera_2d()

func _process(delta):
	# Every 1/attempt_frequency seconds 
	if Time.get_ticks_msec()-last_attempt > 1000.0/attempt_frequency:
		attempt_spawn()
		last_attempt = Time.get_ticks_msec()
	
var empty_tiles_relative = [Vector2(0,-2), Vector2(-1,-2), Vector2(1,-2), Vector2(0,-1), Vector2(-1,-1), Vector2(1,-1)]
func attempt_spawn():
	var pos = generate_spawn_position()
	
	var tile_coords = GameWorld.instance.global_to_tile_coordinates(pos)
	
	var floor_tile = GameWorld.instance.get_tile(tile_coords.x, tile_coords.y)
	var drop_height = 0
	while (floor_tile == null or floor_tile.item == null):
		tile_coords.y += 1
		floor_tile = GameWorld.instance.get_tile(tile_coords.x, tile_coords.y)
		drop_height += 1
		if drop_height > 20:
			return
	
	pos.y += drop_height*8
	var camera_rect : Rect2 = cam_reference.get_canvas_transform().affine_inverse()*get_viewport().get_visible_rect()
	if camera_rect.has_point(pos):
		return
	
	for offset in empty_tiles_relative:
		var coords = tile_coords+offset
		var tile = GameWorld.instance.get_tile(coords.x, coords.y)
		if tile != null and tile.item != null:
			return
	

	var spawned_enemy = enemy_scene.instantiate()
	spawned_enemy.position = pos
	add_child(spawned_enemy)
	
func generate_spawn_position():
	# get world coordinates of viewport
	var rect : Rect2 = cam_reference.get_canvas_transform().affine_inverse()*get_viewport().get_visible_rect()
	
	# get random offset
	var rng = RandomNumberGenerator.new()
	var x = rng.randf_range(rect.position.x-100,rect.position.x+rect.size.x+100)
	var y = rng.randf_range(rect.position.y-100, rect.position.y+rect.size.y+100)
	
	return Vector2(x,y)
