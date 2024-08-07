extends Sprite2D

var holding_tool = false

func _process(_delta):
	if Input.is_key_pressed(KEY_SHIFT) and holding_tool:
		visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	global_position = GameWorld.instance.get_local_mouse_position()

func _ready():
	InventoryInterface.instance.selected_item_changed.connect(selected_item_updated)

func selected_item_updated(item : Item):
	holding_tool = item is ToolItem
