extends Node2D

@export var player : CharacterMovement

var min_bounds : Vector2
var max_bounds : Vector2

var screen_width = 640
var screen_height = 360

func _ready():
	if GameWorld.instance.loading_world:
		GameWorld.instance.world_finished_loading.connect(set_bounds)
	else:
		set_bounds()

func set_bounds():
	min_bounds = Vector2(screen_width/2.0, screen_height/2.0)
	max_bounds = GlobalReferences.TILE_SIZE * Vector2(GameWorld.instance.gameSave.get_width(), GameWorld.instance.gameSave.get_height())
	max_bounds -= Vector2(screen_width/2.0, screen_height/2.0)

func _process(_delta):
	position = player.sprite_holder.global_position
	position.x = clamp(position.x, min_bounds.x, max_bounds.x)
	position.y = clamp(position.y, min_bounds.y, max_bounds.y)
