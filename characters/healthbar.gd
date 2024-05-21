extends Sprite2D

@export var health_node : Health

func _ready():
	health_node.damaged.connect(update_sprite)

func update_sprite():
	var percent_health = health_node.get_percent_health()
	region_rect.position.x = (1-percent_health)*region_rect.size.x
