class_name Multiblock
extends Node2D

var composite_tiles : Array[Tile]

signal destroyed
var breaking = false

func on_broken():
	if !breaking:
		breaking = true
		for tile in composite_tiles:
			tile.destroy()
		
		destroyed.emit()
		queue_free()
