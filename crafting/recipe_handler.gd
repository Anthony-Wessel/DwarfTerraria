class_name RecipeHandler
extends Node

static var recipes : Array[Recipe]
var path = "res://crafting/recipes/"

func _init():
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".remap"):
				file_name = file_name.replace(".remap", "")
			
			recipes.append(load(path + file_name))
			file_name = dir.get_next()
		dir.list_dir_end()
