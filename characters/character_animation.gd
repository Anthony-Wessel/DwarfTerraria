extends AnimationPlayer

@export var character_movement : CharacterMovement
var anim_locked := false

func _process(delta):
	if character_movement.velocity.length() > 0:
		_set_animation("run")
	else:
		_set_animation("idle")
	"""
	if anim_locked:
		if !is_playing():
			anim_locked = false
		else:
			return
	
	if character_movement.is_on_floor():
		if character_movement.velocity.length() > 0:
			_set_animation("run")
		else:
			_set_animation("idle")
	elif character_movement.is_on_wall() and character_movement.velocity.y > 0:
		_set_animation("open_door")
	else:
		_set_animation("airborne")
"""

func _set_animation(new_anim : String):
	if current_animation == new_anim:
		return
	
	play(new_anim)
