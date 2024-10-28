extends Node2D

@export var helmet_sprite : Sprite2D
@export var chest_sprite : Sprite2D
@export var legs_sprite : Sprite2D
@export var boots_sprite : Sprite2D

func _ready():
	GlobalReferences.armor_equipped.connect(on_armor_changed)

func on_armor_changed(type : EquipmentItem.Type, item : EquipmentItem):
	var spritesheet : Texture2D = null
	if item != null:
		spritesheet = item.spritesheet
	
	match type:
		EquipmentItem.Type.HELMET:
			helmet_sprite.texture = spritesheet
		EquipmentItem.Type.TORSO:
			chest_sprite.texture = spritesheet
		EquipmentItem.Type.LEGS:
			legs_sprite.texture = spritesheet
		EquipmentItem.Type.BOOTS:
			boots_sprite.texture = spritesheet
