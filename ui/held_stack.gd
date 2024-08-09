extends TextureRect

func _ready():
	InventoryInterface.instance.held_stack_changed.connect(update)

func update(stack : ItemStack):
	if stack.item == null:
		visible = false
	else:
		visible = true
		texture = stack.item.texture
		if stack.count > 1:
			$HeldCount.text = str(stack.count)
			$HeldCount.visible = true
		else:
			$HeldCount.visible = false
