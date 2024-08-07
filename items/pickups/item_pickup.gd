extends RigidBody2D

var item_stack : ItemStack


func enable(item_ : Item, position_ : Vector2):
	item_stack = ItemStack.new(item_, 1)
	$Sprite2D.texture = item_.texture
	position = position_

func _on_player_entered(_body):
	item_stack = InventoryInterface.player_inventory.add_stack(item_stack)
	if item_stack.item == null:
		queue_free()
