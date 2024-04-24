class_name WorldGenerator
extends Node

static func GenerateWorld(worldResource : GameSave):
	worldResource.tiles.clear()
	
	var default_tile = preload("res://items/tiles/Idirt.tres")
	
	for y in worldResource.height:
		for x in worldResource.width:
			worldResource.tiles.append(default_tile)
