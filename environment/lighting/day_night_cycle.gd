class_name DayNightCycle
extends Node

static var instance

var current_time : float = 0
var max_time : float = 60*24
var night_start_time : float = 60*14
var night_shift_duration : float = 30

func get_clock_time() -> String:
	var adjusted_time = current_time + 60*6
	if adjusted_time > max_time:
		adjusted_time = adjusted_time - max_time
	
	var hours = adjusted_time/max_time * 24.0
	var minutes = (hours - floor(hours)) * 60
	
	if hours > 12:
		hours = hours-12
	
	var hours_str = str(floor(hours))
	if hours_str == "0":
		hours_str = "12"
	var minutes_str = str(floor(minutes))
	if minutes_str.length() == 1:
		minutes_str = "0"+minutes_str
	
	return hours_str + ":" + minutes_str

func get_daylight() -> float:
	if current_time < night_start_time:
		if current_time < night_shift_duration:
			return lerp(10.0, 30.0, current_time / night_shift_duration)
		else:
			return 30
	elif current_time > night_start_time + night_shift_duration:
		return 10.0
	else:
		return lerp(30.0,10.0,(current_time-night_start_time)/night_shift_duration)

func is_shifting() -> bool:
	var shifting_to_night = current_time > night_start_time and current_time < night_start_time + night_shift_duration
	var shifting_to_day = current_time > 0 and current_time < night_shift_duration
	
	return shifting_to_night or shifting_to_day

func _init():
	instance = self
	current_time = 60*13

func _process(delta):
	if Input.is_key_pressed(KEY_BRACKETRIGHT):
		current_time += delta*40
	else:
		current_time += delta
	if current_time > max_time:
		current_time -= max_time
