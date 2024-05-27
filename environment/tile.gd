class_name Tile
extends Node2D

signal broke
signal placed

var empty := true
var collision_enabled := false
var coordinates : Vector2

var tier : int
var max_health : float
var remaining_health : float

var light_level := 0
var light_source := 0
var light_parent := Vector2(0,0)

var item_drop : Item

func mine(mining_tier : int, amount : float) -> bool :
	if mining_tier < tier:
		return false
	remaining_health -= amount*(1+(mining_tier-tier+1)*0.2)
	if remaining_health <= 0:
		destroy()
		return true
	
	var percent_mined = 1-remaining_health/max_health
	$MiningAnimation.frame = int(percent_mined*4)
	return false

func destroy():
	$Sprite2D.texture = null
	$CollisionShape2D.disabled = true
	empty = true
	collision_enabled = false
	$MiningAnimation.frame = 0
	PickupFactory.Instance.spawn_pickup(item_drop, position+Vector2(GlobalReferences.TILE_SIZE/2,GlobalReferences.TILE_SIZE/2))
	item_drop = null
	broke.emit()

func place(texture : Texture2D, collision_enabled : bool, health : float, mining_tier : int):
	$Sprite2D.texture = texture
	$CollisionShape2D.disabled = !collision_enabled
	self.collision_enabled = collision_enabled
	remaining_health = health
	max_health = health
	$MiningAnimation.frame = 0
	empty = false
	tier = mining_tier
	placed.emit()

func set_light_level(level : int):
	light_level = level
	$Sprite2D.modulate = Color(1.0,1.0,1.0)*level/15
	$Sprite2D.modulate.a = 1.0

func set_coordinates(coords : Vector2):
	coordinates = coords
	position = coords*GlobalReferences.TILE_SIZE
