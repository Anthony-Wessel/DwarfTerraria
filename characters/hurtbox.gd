extends Area2D

signal hit

func _on_area_entered(area):
	# TODO: Deal damage to player
	(area as Hitbox).handle_hit(1, global_position)
	hit.emit()
