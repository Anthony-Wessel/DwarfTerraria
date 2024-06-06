extends Area2D

signal interacted

var hovered : bool

func _input(event):
	if !hovered:
		return
	
	var mb_event = event as InputEventMouseButton
	if mb_event and mb_event.button_index == 2 and mb_event.pressed:
		interacted.emit()


func _on_mouse_entered():
	hovered = true


func _on_mouse_exited():
	hovered = false


var tile_coords : Vector2
var world : GameWorld
var tile : TileResource
func setup(game_world : GameWorld, coords : Vector2):
	tile_coords = coords
	world = game_world
	tile = world.get_tile(coords)

func _process(delta):
	if world.get_tile(tile_coords) != tile:
		queue_free()
