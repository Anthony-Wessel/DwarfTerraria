extends StaticBody2D

func setup(size : Vector2, pos : Vector2):
	position = pos
	var rect = RectangleShape2D.new()
	rect.size = size
	get_child(0).shape = rect
