extends Control

@export var target_resolution : Vector2i

func _ready():
	resize()
	get_tree().get_root().size_changed.connect(resize)

func resize():
	var viewport_resolution = get_viewport_rect().size
	scale.x = viewport_resolution.x/target_resolution.x
	scale.y = viewport_resolution.y/target_resolution.y
