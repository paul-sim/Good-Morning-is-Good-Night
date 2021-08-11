extends Node2D

var _day1_preload = preload("res://Scenes/Day1.tscn")
onready var _save_manager = get_owner().find_node("SaveManager")
onready var _player = get_owner().find_node("Player")
onready var _audio_controller = get_owner().find_node("AudioController")


onready var _current_day_object = $Day3
var _previous_day_object = null
onready var _rain = $Day2/Rain

var _day_transitioning = false
var _rain_rotation_degrees = 0
var _raining = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# starts in day3
	hide_area2Ds(get_tree().get_nodes_in_group("Day1_Area2D")) # get all nodes in group "DayX_Area2D". all area2D's should be assigned a group via inspector/node window
	hide_area2Ds(get_tree().get_nodes_in_group("Day2_Area2D"))
	show_area2Ds(get_tree().get_nodes_in_group("Day3_Area2D"))
	get_parent().find_node("Day1").modulate.a = 0
	get_parent().find_node("Day2").modulate.a = 0
	get_parent().find_node("Day3").modulate.a = 1
	_audio_controller.play_music_abruptly("Day3_v02_01.ogg")
	#_audio_controller.play_ambiance("night_ambiance.ogg")
	# transition_to_day(ConstsEnums.DAY.THREE, ConstsEnums.DAY.TWO)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _day_transitioning:
		if _current_day_object.modulate.a >= 1:
			_current_day_object.modulate.a = 1
			_previous_day_object.modulate.a = 0
			_day_transitioning = false
		_current_day_object.modulate.a += ConstsEnums.SKY_TRANSITION_SPEED * delta
		_previous_day_object.modulate.a -= ConstsEnums.SKY_TRANSITION_SPEED * delta
	if _raining:
		_rain_rotation_degrees = lerp(_rain_rotation_degrees, _player.get_rotation_degrees(), ConstsEnums.CELESTIAL_ROTATE_LERP_SPEED * delta)
		_rain.rotation_degrees = _rain_rotation_degrees

func entered_door(area_name):
	if area_name == "Forward_Area2D":
		transition_to_day(_current_day_object.get_day() + 1, _current_day_object.get_day())
	if area_name == "Backward_Area2D":
		transition_to_day(_current_day_object.get_day() - 1, _current_day_object.get_day())
	_day_transitioning = true

func transition_to_day(new_day, previous_day):
	hide_area2Ds(get_tree().get_nodes_in_group("Day" + str(previous_day) + "_Area2D")) # get all nodes in group "DayX_Area2D". all area2D's should be assigned a group via inspector/node window
	show_area2Ds(get_tree().get_nodes_in_group("Day" + str(new_day) + "_Area2D"))
	_previous_day_object = _current_day_object
	_current_day_object = find_node("Day" + str(new_day)) # assign new day to be the current day object
	if new_day == ConstsEnums.DAY.TWO:
		_raining = true
	else:
		_raining = false
	#audio
	match new_day:
		ConstsEnums.DAY.ONE:
			_audio_controller.stop_rain()
			_audio_controller.play_music("Day1_v01_01.ogg")
		ConstsEnums.DAY.TWO:
			_audio_controller.play_rain()
			_audio_controller.play_music("Day2_v01_01.ogg")
		ConstsEnums.DAY.THREE:
			_audio_controller.stop_rain()
			_audio_controller.play_music("Day3_v02_01.ogg")
			

# move away area2Ds that are of the day we are transitioning out of so that the player won't trigger them
func hide_area2Ds(areas):
	for a in areas:
		a.position = ConstsEnums.HIDE_VECTOR

func show_area2Ds(areas):
	for a in areas:
		a.position = Vector2.ZERO # we return all triggers to their rightful location and that's how we "activate" them

func get_current_day_object():
	return _current_day_object
