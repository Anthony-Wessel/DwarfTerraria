class_name TileHandler
extends Node

static var tiles : Array[TileResource]
var path = "res://tiles/resources/"

static var EMPTY_TILE
static var EMPTY_WALL

func _init():
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		while file_name != "":
			var t_resource = load(path + file_name) as TileResource
			
			if t_resource.name == "empty tile": EMPTY_TILE = t_resource
			if t_resource.name == "empty wall": EMPTY_WALL = t_resource
			
			if tiles.size() == 0 or tiles[-1].id < t_resource.id:
				tiles.append(t_resource)
			else:
				for i in tiles.size():
					if tiles[i].id == t_resource.id:
						var err = "Duplicate tile resource id: " + str(t_resource.id)
						err += " (" + tiles[i].name + " and " + t_resource.name + ")"
						push_error(err)
					if tiles[i].id > t_resource.id:
						tiles.insert(i, t_resource)
						break
			
			file_name = dir.get_next()
		dir.list_dir_end()
	
	#for r in tiles:
		#print(r.id, " : ", r.name)
