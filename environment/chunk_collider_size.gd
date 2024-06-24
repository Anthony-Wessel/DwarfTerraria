extends CollisionShape2D

func _ready():
	(shape as RectangleShape2D).size = Vector2(8,8) * GlobalReferences.CHUNK_SIZE
	position = (shape as RectangleShape2D).size / 2
