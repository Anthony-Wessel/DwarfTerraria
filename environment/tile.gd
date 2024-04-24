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
			remaining_health = value.mining_time
		else:
			$Sprite2D.texture = null
			$CollisionShape2D.disabled = true
			$MiningAnimation.frame = 0

var remaining_health : float :
	get:
		return remaining_health
	set(value):
		remaining_health = value
		var percent_mined = 1-remaining_health/item.mining_time
		$MiningAnimation.frame = int(percent_mined*4)
