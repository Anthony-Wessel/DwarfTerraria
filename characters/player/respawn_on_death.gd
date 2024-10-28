extends Node

@export var root_node : Node2D

func respawn():
	root_node.position = GameWorld.instance.get_player_spawn() * GlobalReferences.TILE_SIZE
	get_parent().reset_health()
