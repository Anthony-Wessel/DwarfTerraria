extends CharacterBody2D

@export var anim : AnimationPlayer

var circle_speed = 75
var circle_distance = 100
var chase_speed = 100

var player : Node2D

var state = 0
# 0 - idle
# 1 - circle player
# 2 - chase player
# 3 - run away

func set_attack_state():
	state = 2
	$SpriteHolder/AttackCollider/CollisionShape2D.disabled = false
	
func set_circle_state():
	state = 1
	$SpriteHolder/AttackCollider/CollisionShape2D.disabled = true
	$Timer.timeout.connect(set_attack_state)
	$Timer.start(4)

func _ready():
	set_circle_state()

func _process(delta):
	if player == null:
		player = GlobalReferences.player
		return
		

	var diff : Vector2 = player.position - position
	var movement : Vector2
	
	if state == 1: # circle player
		var perp = Vector2(diff.y, -diff.x).normalized()
		if diff.length() - circle_distance > 5:
			movement = (perp + diff.normalized()).normalized() * circle_speed
		elif diff.length() - circle_distance < -5:
			movement = (perp + -diff.normalized()).normalized() * circle_speed
		else:
			movement = perp * circle_speed
	elif state == 2: # chase player
		movement = diff.normalized() * chase_speed
		if diff.length() < 5:
			set_circle_state()
	elif state == 3: # run away from player
		movement = -diff.normalized() * chase_speed
	
	position += movement * delta


func _on_attack_collision(body):
	print(body)
