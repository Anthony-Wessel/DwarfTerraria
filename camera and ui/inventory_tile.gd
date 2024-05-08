class_name InventoryTile
extends TextureRect

@export var item_sprite : TextureRect
@export var count_text : Label

func update(stack : Inventory.ItemStack):
	if stack.item == null:
		item_sprite.texture = null
		count_text.text = ""
		return
	
	item_sprite.texture = stack.item.texture
	count_text.text = str(stack.count)
