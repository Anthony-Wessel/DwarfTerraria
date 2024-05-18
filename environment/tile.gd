class_name Tile
extends Node2D

signal broke

var empty := true
var collision_enabled := false

var tier : int
var max_health : float
var remaining_health : float

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
	$MiningAnimation.frame = 0
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
