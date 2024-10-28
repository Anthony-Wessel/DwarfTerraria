extends Node2D

var circle_speed = 60
var circle_distance = 70
var chase_speed = 80

var player : Node2D

var state = 0
# 0 - idle
# 1 - circle player
# 2 - chase player
# 3 - run away

func set_attack_state():
	state = 2
	
func set_circle_state():
	state = 1
	$Timer.start(4)

func _ready():
	$Timer.timeout.connect(set_attack_state)
	set_circle_state()

func _process(delta):
	if player == null:
		player = Player.instance
		return

	var diff : Vector2 = (player.global_position + Vector2(0,-GlobalReferences.TILE_SIZE*1.5))- global_position
	var movement : Vector2
	
	if state == 1: # circle player
		var perp = Vector2(diff.y, -diff.x).normalized()
		if diff.length() - circle_distance > GlobalReferences.TILE_SIZE/2.0:
			movement = (perp + diff.normalized()).normalized() * circle_speed
		elif diff.length() - circle_distance < -GlobalReferences.TILE_SIZE/2.0:
			movement = (perp + -diff.normalized()).normalized() * circle_speed
		else:
			movement = perp * circle_speed
	elif state == 2: # chase player
		movement = (diff+Vector2(0,-5)).normalized() * chase_speed
		if diff.length() < GlobalReferences.TILE_SIZE/2.0:
			set_circle_state()
	elif state == 3: # run away from player
		movement = -diff.normalized() * chase_speed
	
	position += movement * delta
	
	
	if diff.x < 0:
		$SpriteHolder.scale.x = -1
	elif diff.x > 0:
		$SpriteHolder.scale.x = 1


func _on_attack_collision():
	set_circle_state()

func on_hit(_damage, _collision_position):
	set_circle_state()
