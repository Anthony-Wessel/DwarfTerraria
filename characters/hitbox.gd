class_name Hitbox
extends Area2D

@export var immunity_length := 0.0
@export var sprite : Sprite2D

var immune := false

signal hit(damage : float, collision_position : Vector2)

# This object was hit by an attack
func handle_hit(damage : float, collision_position : Vector2):
	if immune:
		return
		
	hit.emit(damage, collision_position)
	
	if immunity_length > 0:
		trigger_immunity()

func trigger_immunity():
	immune = true
	
	var tween = get_tree().create_tween()
	for i in 5:
		tween.tween_property(sprite, "modulate", Color(sprite.modulate, 0.5), immunity_length/10.0)
		tween.tween_property(sprite, "modulate", Color(sprite.modulate, 1), immunity_length/10.0)
	
	await get_tree().create_timer(immunity_length).timeout
	immune = false


# This object 
func _on_area_entered(area):
	# TODO: Deal damage to player
	(area as Hitbox).handle_hit(1, global_position)
	hit.emit(0, global_position)
