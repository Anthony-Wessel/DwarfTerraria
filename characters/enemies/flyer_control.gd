extends Node

var player : Node2D
@export var movement : FlyingMovement

var speed := 75.0

enum State {
	FLAPPING,
	DIVING,
	RECOVERING
}
var current_state := State.RECOVERING

func _ready():
	player = Player.instance
	get_tree().create_timer(3).timeout.connect(swap_states)

func _process(_delta):
	if current_state == State.FLAPPING:
		pass
	elif current_state == State.DIVING:
		var dir = (player.global_position+Vector2(0,-GlobalReferences.TILE_SIZE*1.5))-movement.global_position
		dir.y = dir.y * 2
		dir = dir.normalized()
		movement.update_velocity(dir*speed*2)
	elif current_state == State.RECOVERING:
		var dir = movement.velocity
		dir.y -= 1
		dir = dir.normalized()
		movement.update_velocity(dir*speed)
	
	
func swap_states():
	current_state = State.DIVING
	get_tree().create_timer(4).timeout.connect(on_hit_player)

func on_hit_player():
	current_state = State.RECOVERING
	get_tree().create_timer(2).timeout.connect(swap_states)

func on_hit(_damage : float, _collision_position : Vector2):
	current_state = State.RECOVERING
	get_tree().create_timer(2).timeout.connect(swap_states)
