extends Node2D

var player : Node2D
@export var character_movement : CharacterMovement
@export var floor_detector : TileDetector
@export var obstacle_detector : TileDetector

func _process(_delta):
	if player == null:
		player = Player.instance
		return
	
	var diff = player.global_position - global_position

	character_movement.set_horizontal_movement(sign(diff.x))

	var jump = false
	if obstacle_detector.is_floor_detected() and floor_detector.is_floor_detected():
		pass#jump = true
	elif !floor_detector.is_floor_detected() and (!diff.y>GlobalReferences.TILE_SIZE/2.0):
		jump = true
		
	if jump and character_movement.velocity.y >= 0:
		character_movement.jump()
