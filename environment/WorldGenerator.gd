class_name WorldGenerator
extends Node

static var default_tile_resource = preload("res://Tile Resources/Tdirt.tres")

static func GenerateWorld(worldResource : GameSave):
	worldResource.tiles.clear()
	
	for y in worldResource.height:
		for x in worldResource.width:
			worldResource.tiles.append(default_tile_resource)
