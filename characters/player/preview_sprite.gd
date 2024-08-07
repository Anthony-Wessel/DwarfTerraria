extends Node2D

static var instance

var sprites : Array[Sprite2D]
var area : Area2D
var collision_shape : CollisionShape2D
var check_for_updates := false
var prev_pos : Vector2i
var overlapping_player := false
var tile_grid
var preview_intersections : Array[bool]
var held_item : PlaceableItem

func _ready():
	for child in get_children():
		if child is Sprite2D:
			sprites.append(child)
		else:
			area = child
			collision_shape = child.get_child(0)
	
	tile_grid = GameWorld.instance
	for i in 9:
		preview_intersections.append(false)
	
	InventoryInterface.instance.selected_item_changed.connect(on_item_changed)

func on_item_changed(new_item : Item):
	if new_item is PlaceableItem:
		held_item = new_item
		check_for_updates = true
		update_texture(new_item.texture)
	else:
		held_item = null
		check_for_updates = false
		update_texture(null)
		

func _process(_delta):
	if !check_for_updates:
		return
	
	# check for new tile position
	var tile_pos = Vector2i(tile_grid.get_local_mouse_position()/GlobalReferences.TILE_SIZE)
	if tile_pos != prev_pos:
		update_preview_sprite(tile_pos)
		prev_pos = tile_pos

func update_preview_sprite(new_pos : Vector2i):
	global_position = tile_grid.global_position+Vector2(new_pos)*GlobalReferences.TILE_SIZE
	
	# Don't place a tile if it is out of reach
	var distance_to_player = global_position - (Vector2(new_pos)*GlobalReferences.TILE_SIZE)
	if distance_to_player.length() > 5*GlobalReferences.TILE_SIZE:
		for i in preview_intersections.size():
			preview_intersections[i] = true
	else:
		for i in preview_intersections.size():
			preview_intersections[i] = false
		
		
		var placing_wall = TileHandler.tiles[held_item.tile_ids[0]].wall
		for a in held_item.size.x:
			for b in held_item.size.y:
				if !tile_grid.is_tile_empty(new_pos + Vector2i(a,b), placing_wall):
					preview_intersections[a+b*3] = true
				else:
					preview_intersections[a+b*3] = false
	
	update_colors()


func update_texture(texture : Texture2D):
	for sprite in sprites:
		sprite.texture = null
	
	if texture != null:
		@warning_ignore("integer_division")
		var width = texture.get_width()/GlobalReferences.TILE_SIZE
		@warning_ignore("integer_division")
		var height = texture.get_height()/GlobalReferences.TILE_SIZE
		
		set_collider_size(Vector2(width, height))
		
		for x in width:
			for y in height:
				sprites[x + y*3].texture = texture

func update_colors():
	for i in preview_intersections.size():
		if overlapping_player or preview_intersections[i]:
			sprites[i].self_modulate = Color(1,0,0,0.5)
		else:
			sprites[i].self_modulate = Color(0,1,0,0.5)

func clear():
	for sprite in sprites:
		sprite.texture = null

func set_collider_size(size : Vector2):
	collision_shape.shape.size = size * GlobalReferences.TILE_SIZE
	collision_shape.position = size * GlobalReferences.TILE_SIZE/2.0


func _on_player_entered(_body):
	overlapping_player = true

func _on_player_exited(_body):
	overlapping_player = false

func can_place() -> bool:
	if overlapping_player:
		return false
	
	for intersection in preview_intersections:
		if intersection:
			return false
	
	return true
