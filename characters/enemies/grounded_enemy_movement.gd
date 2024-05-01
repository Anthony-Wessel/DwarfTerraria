extends Node2D

var player : Node2D
@export var character_movement : CharacterMovement
@export var floor_detector : TileDetector
@export var obstacle_detector : TileDetector

func _process(delta):
	if player == null:
		player = Player.instance
		return
	
	var diff = player.global_position - global_position

	character_movement.set_horizontal_movement(sign(diff.x))

	var jump = false
	if obstacle_detector.is_floor_detected() and floor_detector.is_floor_detected():
		jump = true
	elif !floor_detector.is_floor_detected() and (!diff.y>5):
		jump = true
		
	if jump and character_movement.velocity.y >= 0:
		character_movement.jump()


func _on_collided_with_player(area):
	# TODO: Deal damage to player
	var diff = area.global_position - global_position
	(area.get_parent() as CharacterMovement).force_velocity(Vector2(sign(diff.x)*70,-50))
	character_movement.force_velocity(Vector2(0,0))
