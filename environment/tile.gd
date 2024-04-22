class_name Tile
extends Node2D

var item : TileItem :
	get:
		return item
	set(value):
		item = value
		if value != null:
			$Sprite2D.texture = value.texture
			$CollisionShape2D.disabled = false
		else:
			$Sprite2D.texture = null
			$CollisionShape2D.disabled = true
