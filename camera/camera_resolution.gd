extends Camera2D

@export var target_resolution : Vector2i

func _ready():
	pass
	resize()
	get_tree().get_root().size_changed.connect(resize)

func resize():
	var viewport_resolution = get_viewport_rect().size
	zoom.x = viewport_resolution.x/target_resolution.x
	zoom.y = viewport_resolution.y/target_resolution.y
