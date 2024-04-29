class_name TileDetector
extends Area2D

var detected_tiles : Array[Node]

func is_floor_detected():
	return detected_tiles.size() != 0


func _on_tile_detected(body):
	detected_tiles.append(body)


func _on_tile_lost(body):
	detected_tiles.erase(body)
