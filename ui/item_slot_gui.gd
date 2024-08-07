extends TextureRect

var slot : InventorySlot : set = set_slot
func set_slot(value):
	if slot != null:
		slot.contents_updated.disconnect(update_gui)
	
	slot = value
	update_gui()
	
	if value != null:
		slot.contents_updated.connect(update_gui)

func update_gui():
	if slot == null:
		visible = false
	else:
		visible = true
	
		if slot.item == null:
			$ItemTexture.texture = null
			$ItemCount.visible = false
		else:
			$ItemTexture.texture = slot.item.texture
			$ItemCount.text = str(slot.count)
			$ItemCount.visible = true

func _gui_input(event):
	var mb_event = event as InputEventMouseButton
	if mb_event and mb_event.pressed:
		match mb_event.button_index:
			MOUSE_BUTTON_LEFT:
				InventoryInterface.on_slot_interaction(slot, true)
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_RIGHT:
				InventoryInterface.on_slot_interaction(slot, false)
				get_viewport().set_input_as_handled()
