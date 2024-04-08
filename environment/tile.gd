class_name Tile
extends Node2D

var tile_resource : TileRes :
	get:
		return tile_resource
	set(value):
		tile_resource = value
		if value != null:
			$Sprite2D.texture = value.texture
			$CollisionShape2D.disabled = false
		else:
			$Sprite2D.texture = null
			$CollisionShape2D.disabled = true
