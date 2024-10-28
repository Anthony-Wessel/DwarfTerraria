extends Node

var TILE_SIZE := 8
var CHUNK_SIZE := 32

signal texture_generated(Texture2D)

signal armor_equipped(slot : EquipmentItem.Type, item : EquipmentItem)
