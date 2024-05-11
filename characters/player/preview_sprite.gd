extends Node2D

var sprites : Array[Sprite2D]

func _ready():
	for child in get_children():
		sprites.append(child)

func update_texture(texture : Texture2D):
	for sprite in sprites:
		sprite.texture = null
	
	for x in texture.get_width()/8:
		for y in texture.get_height()/8:
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
