extends Node

@export var health := 2
signal got_hit

func get_hit(damage : int, source_position : Vector2):
	health -= damage
	if health <= 0:
		get_parent().queue_free()
	
	var diff = get_parent().position - source_position
	(get_parent() as CharacterBody2D).velocity += Vector2(sign(diff.x) * 50, -70)
	got_hit.emit()
