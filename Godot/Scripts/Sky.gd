extends Node2D

onready var _player = get_owner().find_node("Player")
onready var _sun = $CanvasLayer/Sun
onready var _moon = $CanvasLayer2/Moon
onready var _sun_sprite = $CanvasLayer/Sun/SunPhysical/Sprite
onready var _moon_sprite = $CanvasLayer2/Moon/MoonPhysical/Sprite
onready var _clouds_sprite = $ParallaxBackground/ParallaxLayer/Clouds_Sprite
onready var _stars_sprite = $ParallaxBackground/ParallaxLayer2/Stars_Sprite
onready var _day_sky = $CanvasLayer3/DaySky
onready var _night_sky = $CanvasLayer3/NightSky
onready var _audio_controller = get_parent().get_node("AudioController")

var _sun_moon_rotation_degrees = 0

var _transition_to_night = false
var _transition_to_day = false

# Called when the node enters the scene tree for the first time.
func _ready():
	transition_to_night()
	_audio_controller.play_ambiance("night_ambiance.ogg") # main starts on day 3 night
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _transition_to_night:
		if _stars_sprite.self_modulate.a >= 1: # when transition is complete, force everything to be in the right state in case they get wacky
			_stars_sprite.self_modulate.a = 1
			_clouds_sprite.self_modulate.a = 0
			_night_sky.self_modulate.a = 1
			_day_sky.self_modulate.a = 0
			_transition_to_night = false
			return
		_stars_sprite.self_modulate.a += ConstsEnums.SKY_TRANSITION_SPEED * delta
		_clouds_sprite.self_modulate.a -= ConstsEnums.SKY_TRANSITION_SPEED * delta
		_night_sky.self_modulate.a += ConstsEnums.SKY_TRANSITION_SPEED * delta
		_day_sky.self_modulate.a -= ConstsEnums.SKY_TRANSITION_SPEED * delta
	elif _transition_to_day:
		if _clouds_sprite.self_modulate.a >= 1: # when transition is complete, force everything to be in the right state in case they get wacky
			_clouds_sprite.self_modulate.a = 1
			_stars_sprite.self_modulate.a = 0
			_day_sky.self_modulate.a = 1
			_night_sky.self_modulate.a = 0
			_transition_to_day = false
			return
		_clouds_sprite.self_modulate.a += ConstsEnums.SKY_TRANSITION_SPEED * delta
		_stars_sprite.self_modulate.a -= ConstsEnums.SKY_TRANSITION_SPEED * delta
		_day_sky.self_modulate.a += ConstsEnums.SKY_TRANSITION_SPEED * delta
		_night_sky.self_modulate.a -= ConstsEnums.SKY_TRANSITION_SPEED * delta

func _physics_process(delta):
	_sun_moon_rotation_degrees = lerp(_sun_moon_rotation_degrees, _player.get_rotation_degrees(), ConstsEnums.CELESTIAL_ROTATE_LERP_SPEED * delta)
	_sun.rotation_degrees = _sun_moon_rotation_degrees
	_moon.rotation_degrees = _sun_moon_rotation_degrees
	_sun_sprite.rotation_degrees = 0 - _sun_moon_rotation_degrees # this is so that the sprite itself doesn't rotate, only its position does
	_moon_sprite.rotation_degrees = 0 - _sun_moon_rotation_degrees


func _on_ToNight_Area2D_area_entered(area):
	if area.get_parent().get_parent().name == "Player":
		transition_to_night()
		_audio_controller.play_ambiance("night_ambiance.ogg")

func _on_ToDay_Area2D2_area_entered(area):
	if area.get_parent().get_parent().name == "Player":
		transition_to_day()
		_audio_controller.play_ambiance("morning_ambiance.ogg")

func transition_to_night():
	_transition_to_night = true
	#_transition_to_day = false # in case player activates day transition before night transition finishes
	_audio_controller.play_ambiance("night_ambiance.ogg")
	
func transition_to_day():
	_transition_to_day = true
	#_transition_to_night = false
	_audio_controller.play_ambiance("morning_ambiance.ogg")
