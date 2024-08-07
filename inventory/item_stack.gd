class_name ItemStack
extends Resource

@export var item : Item = null
@export var count : int = 0 : set = set_count
func set_count(value):
	count = value
	if count == 0:
		item = null

func _init(_item=null, _count=0):
	item = _item
	count = _count
