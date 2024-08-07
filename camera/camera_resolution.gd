extends Camera2D

@export var target_resolution : Vector2i

func _ready():
	var viewport_resolution = get_viewport_rect().size
	zoom.x = viewport_resolution.x/target_resolution.x
	zoom.y = viewport_resolution.y/target_resolution.y
