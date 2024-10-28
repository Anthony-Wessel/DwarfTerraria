extends Sprite2D

@export var base_sprite : Sprite2D

func _ready():
	base_sprite.frame_changed.connect(_on_frame_changed)

func _on_frame_changed():
	frame = base_sprite.frame
