extends Node2D

var sprites : Array[Sprite2D]
var area : Area2D
var collision_shape : CollisionShape2D

func _ready():
	for child in get_children():
		if child is Sprite2D:
			sprites.append(child)
		else:
			area = child
			collision_shape = child.get_child(0)

func update_texture(texture : Texture2D):
	for sprite in sprites:
		sprite.texture = null
	
	@warning_ignore("integer_division")
	var width = texture.get_width()/GlobalReferences.TILE_SIZE
	@warning_ignore("integer_division")
	var height = texture.get_height()/GlobalReferences.TILE_SIZE
	
	set_collider_size(Vector2(width, height))
	
	for x in width:
		for y in height:
			sprites[x + y*3].texture = texture

func update_intersections(intersections : Array[bool]):
	for i in intersections.size():
		if intersections[i]:
			sprites[i].self_modulate = Color(1,0,0,0.5)
		else:
			sprites[i].self_modulate = Color(0,1,0,0.5)

func clear():
	for sprite in sprites:
		sprite.texture = null

func is_overlapping_player() -> bool:
	return area.get_overlapping_bodies().size() > 0

func set_collider_size(size : Vector2):
	collision_shape.shape.size = size * GlobalReferences.TILE_SIZE
	collision_shape.position = size * GlobalReferences.TILE_SIZE/2.0
