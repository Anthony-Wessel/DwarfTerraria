extends RigidBody2D

var item : Item


func enable(item_ : Item, position_ : Vector2):
	item = item_
	$Sprite2D.texture = item.texture
	position = position_

func _on_player_entered(body):
	GlobalReferences.player.inventory.add_item(item)
	queue_free()
