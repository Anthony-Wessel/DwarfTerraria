extends Node

@export var root_node : Node

func destroy():
	root_node.queue_free()
