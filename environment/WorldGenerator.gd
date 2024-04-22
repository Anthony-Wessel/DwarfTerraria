class_name WorldGenerator
extends Node

static var default_tile = preload("res://items/Idirt.tres")

static func GenerateWorld(worldResource : GameSave):
	worldResource.tiles.clear()
	
	for y in worldResource.height:
		for x in worldResource.width:
			worldResource.tiles.append(default_tile)
