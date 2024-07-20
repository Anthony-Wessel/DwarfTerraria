extends TextureRect

var textures = []
var index = 0

func _init():
	GlobalReferences.texture_generated.connect(display)

func display(tex : Texture2D):
	textures.append(tex)

func _process(_delta):
	if textures.size() == 0: return
	
	if Input.is_action_just_pressed("Jump"):
		index = (index+1) % textures.size()
		texture = textures[index]
