extends Node2D

onready var _music_animationPlayer = self.find_node("AnimationPlayer")
onready var _music_animationPlayer2 = self.find_node("AnimationPlayer2")
onready var _sfx_animationPlayer = self.find_node("SFX_AnimationPlayer")
onready var _music_audioStreamPlayer = self.find_node("Music_AudioStreamPlayer")
onready var _music_audioStreamPlayer2 = self.find_node("Music_AudioStreamPlayer2")
onready var _sfx_audioStreamPlayer = self.find_node("SFX_AudioStreamPlayer")
onready var _sfx_audioStreamPlayer2 = self.find_node("SFX_AudioStreamPlayer2")
onready var _sfx_audioStreamPlayer2D = get_owner().find_node("SFX_AudioStreamPlayer2D")
onready var _ambiance_audioStreamPlayer = self.find_node("Ambiance_AudioStreamPlayer")
onready var _ambiance_audioStreamPlayer2 = self.find_node("Ambiance_AudioStreamPlayer2")
onready var _ambiance_animationPlayer = self.find_node("Ambiance_AnimationPlayer")
onready var _ambiance_animationPlayer2 = self.find_node("Ambiance_AnimationPlayer2")
onready var _rain_audioStreamPlayer = self.find_node("Rain_AudioStreamPlayer")
onready var _rain_animationPlayer = self.find_node("Rain_AnimationPlayer")
onready var _footstep_audioStreamPlayer = self.find_node("Footstep_AudioStreamPlayer")

var rng = RandomNumberGenerator.new()

var music_switch = true
var ambiance_switch = true
var sfx_switch = true

var _footstep_on = false
var _timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if _footstep_on:
		_timer += delta
		if _timer >= 0.35:
			_timer = 0
			play_footstep_sound()

func play_music_abruptly(music):
	_music_audioStreamPlayer.stream = load("res://Audio/Music/" + music)
	_music_audioStreamPlayer.play()
	music_switch = false

func play_music(music) :
	if music_switch:
		if fade_in_music(music):
			stop_music2()
			music_switch = false
	else:
		if fade_in_music2(music):
			stop_music()
			music_switch = true
	pass

func play_ambiance(ambiance) :
	if ambiance_switch:
		if fade_in_ambiance(ambiance):
			stop_ambiance2()
			ambiance_switch = false
	else:
		if fade_in_ambiance2(ambiance):
			stop_ambiance()
			ambiance_switch = true

func play_rain():
	fade_in_rain()

func stop_rain():
	fade_out_rain()

func fade_in_rain():
	_rain_audioStreamPlayer.stream = load("res://Audio/SFX/rain.ogg")
	_rain_audioStreamPlayer.volume_db = -100
	_rain_audioStreamPlayer.play()
	_rain_animationPlayer.play("Rain_FadeIn")

func fade_out_rain() :
	_rain_animationPlayer.play("Rain_FadeOut")

func fade_in_music(music) -> bool:
	if _music_audioStreamPlayer2.stream != null:
		if _music_audioStreamPlayer2.stream.resource_path == "res://Audio/Music/" + music:
			return false
	
	_music_audioStreamPlayer.stream = load("res://Audio/Music/" + music)
	_music_audioStreamPlayer.volume_db = -100
	_music_audioStreamPlayer.play()
	_music_animationPlayer.play("Music_FadeIn")
	return true

func fade_in_ambiance(ambiance) -> bool:
	if _ambiance_audioStreamPlayer2.stream != null:
		if _ambiance_audioStreamPlayer2.stream.resource_path == "res://Audio/SFX/" + ambiance:
			return false
	
	_ambiance_audioStreamPlayer.stream = load("res://Audio/SFX/" + ambiance)
	_ambiance_audioStreamPlayer.volume_db = -100
	_ambiance_audioStreamPlayer.play()
	_ambiance_animationPlayer.play("Ambiance_FadeIn")
	return true
	
func fade_in_ambiance2(ambiance) -> bool:
	if _ambiance_audioStreamPlayer.stream != null:
		if _ambiance_audioStreamPlayer.stream.resource_path == "res://Audio/SFX/" + ambiance:
			return false
	
	_ambiance_audioStreamPlayer2.stream = load("res://Audio/SFX/" + ambiance)
	_ambiance_audioStreamPlayer2.volume_db = -100
	_ambiance_audioStreamPlayer2.play()
	_ambiance_animationPlayer2.play("Ambiance_FadeIn")
	return true
	
func fade_in_music2(music) -> bool:
	if _music_audioStreamPlayer.stream != null:
		if _music_audioStreamPlayer.stream.resource_path == "res://Audio/Music/" + music:
			return false
			
	_music_audioStreamPlayer2.stream = load("res://Audio/Music/" + music)
	_music_audioStreamPlayer2.volume_db = -100
	_music_audioStreamPlayer2.play()
	_music_animationPlayer2.play("Music_FadeIn")
	return true

func stop_music() :
	_music_animationPlayer.play("Music_FadeOut")
func stop_music2() :
	_music_animationPlayer2.play("Music_FadeOut")

func stop_ambiance() :
	_ambiance_animationPlayer.play("Ambiance_FadeOut")
func stop_ambiance2() :
	_ambiance_animationPlayer2.play("Ambiance_FadeOut")

func play_SFX(sfx) :
	if sfx_switch:
		play_sound(sfx)
		sfx_switch = false
	else:
		play_sound2(sfx)
		sfx_switch = true

func play_sound(sfx) :
	if (_sfx_audioStreamPlayer.stream_paused == true) :
		_sfx_audioStreamPlayer.stream_paused = false
	_sfx_audioStreamPlayer.stream = load("res://Audio/SFX/" + sfx)
	rng.randomize()
	var num = rng.randf_range(-0.2, 0.2)
	_sfx_audioStreamPlayer.pitch_scale = 1 + num
	_sfx_audioStreamPlayer.play()

func play_sound2(sfx) :
	if (_sfx_audioStreamPlayer2.stream_paused == true) :
		_sfx_audioStreamPlayer2.stream_paused = false
	_sfx_audioStreamPlayer2.stream = load("res://Audio/SFX/" + sfx)
	rng.randomize()
	var num = rng.randf_range(-0.2, 0.2)
	_sfx_audioStreamPlayer2.pitch_scale = 1 + num
	_sfx_audioStreamPlayer2.play()

func stop_SFX() :
	_sfx_audioStreamPlayer.stream_paused = true

func play_SFX2D(sfx) :
	if (_sfx_audioStreamPlayer2D.stream_paused == true) :
		_sfx_audioStreamPlayer2D.stream_paused = false
	_sfx_audioStreamPlayer2D.stream = load("res://Audio/SFX/" + sfx)
	_sfx_audioStreamPlayer2D.play()

func _on_Music_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Music_FadeOut" || anim_name == "long_fadeout"):
		_music_audioStreamPlayer.stream = load("")
		# _music_audioStreamPlayer.stream = null
		# _music_audioStreamPlayer.stream_paused = true
		# _music_audioStreamPlayer.stop() # music is faded out so stop playing it
		_music_animationPlayer.play("Music_Init") # this resets the music volume to original so that next song played will have volume

func play_long_fade():
	_sfx_animationPlayer.play("long_fadeout")
	if (music_switch):
		_music_animationPlayer2.play("long_fadeout")
	else:
		_music_animationPlayer.play("long_fadeout")

func play_footstep_sound():
	rng.randomize()
	var num = rng.randi_range(1, 4)
	_footstep_audioStreamPlayer.stream = load("res://Audio/SFX/footstep_grass_" + str(num) + ".ogg")
	_footstep_audioStreamPlayer.play()

func play_footstep():
	_footstep_on = true
	# play_footstep_sound()

func stop_footstep():
	_footstep_on = false
