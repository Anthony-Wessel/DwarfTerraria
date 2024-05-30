extends Sprite2D

var node_to_follow : Node2D
var follow_offset : Vector2

func _ready():
	node_to_follow = get_parent()
	follow_offset = position
	
	DynamicLights.attach_light(self)

func _process(delta):
	if node_to_follow == null:
		queue_free()
	else:
		global_position = node_to_follow.global_position + offset
