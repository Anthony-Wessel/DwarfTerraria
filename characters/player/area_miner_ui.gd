extends Sprite2D

@export var item_user : Node2D

func _process(_delta):
	if Input.is_key_pressed(KEY_SHIFT) and item_user.held_item is ToolItem:
		visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	global_position = GameWorld.instance.get_local_mouse_position()
	
