extends Node2D

@export var player : CharacterMovement

var min_bounds : Vector2
var max_bounds : Vector2

var screen_width = 640
var screen_height = 360

func set_bounds():
	min_bounds = Vector2(screen_width/2, screen_height/2)
	max_bounds = GlobalReferences.TILE_SIZE * Vector2(GameWorld.instance.gameSave.width, GameWorld.instance.gameSave.width)
	max_bounds -= Vector2(screen_width/2, screen_height/2)

func _process(delta):
	position = player.sprite_holder.global_position
	position.x = clamp(position.x, min_bounds.x, max_bounds.x)
	position.y = clamp(position.y, min_bounds.y, max_bounds.y)
