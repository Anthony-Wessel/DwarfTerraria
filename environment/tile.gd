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
signal light_changed(int)

var item_drop : Item

var dependents : Array[Tile]

func mine(mining_tier : int, amount : float) -> bool :
	if mining_tier < tier:
		return false
	remaining_health -= amount*(1+(mining_tier-tier+1)*0.2)
	if remaining_health <= 0:
		destroy()
		return true
	
	var percent_mined = 1-remaining_health/max_health
	$MiningAnimation.visible = true
	$MiningAnimation.frame = int(percent_mined*4)
	return false

func destroy():
	$Sprite2D.texture = null
	$Sprite2D.visible = false
	
	$MiningAnimation.frame = 0
	$MiningAnimation.visible = false
	
	$CollisionShape2D.disabled = true
	collision_enabled = false
	empty = true
	
	light_source = 0
	
	PickupFactory.instance.spawn_pickup(item_drop, position + Vector2(0.5, 0.5)*GlobalReferences.TILE_SIZE)
	item_drop = null
	
	for dependent in dependents:
		if !dependent.empty: # will destroy newly placed tile, need to remove dependent when it is destroyed early
			dependent.destroy()
	dependents.clear()
	
	broke.emit()

func place(texture : Texture2D, collision_enabled : bool, health : float, mining_tier : int, light : int):
	$Sprite2D.texture = texture
	$Sprite2D.visible = true
	$MiningAnimation.frame = 0
	
	$CollisionShape2D.disabled = !collision_enabled
	self.collision_enabled = collision_enabled
	empty = false
	
	remaining_health = health
	max_health = health
	
	tier = mining_tier
	
	light_source = light
	
	placed.emit()

func set_light_level(level : int):
	light_level = level
	light_changed.emit(level)

func set_coordinates(coords : Vector2):
	coordinates = coords
	position = coords*GlobalReferences.TILE_SIZE

func add_dependent(tile : Tile):
	dependents.append(tile)
