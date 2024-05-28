extends Node2D

func update_light(level : int):
	var val = level/15.0
	$Sprite2D.modulate = Color(val,val,val, 1.0)
