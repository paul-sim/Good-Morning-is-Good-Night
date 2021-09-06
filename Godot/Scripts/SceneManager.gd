extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var _audio_controller = get_owner().find_node("AudioController")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func change_scene(scene):
	if get_parent().name == "FlatWorld1": 	# going to main
		get_owner().find_node("PlayerFlatWorld").disable_movement()
		get_owner().get_node("AudioController").play_earthquake()
		$AnimationPlayer.play("GetTimeMachine")
		#$AnimationPlayer.queue("Idle")
		# fade out fireflies, otherwise they shine through the white screen
		var temp_flies = get_parent().get_node("StaticProps/Ricefield_Dirt")
		var temp_flies2 = get_parent().get_node("StaticProps/Bridge_FG")
		if temp_flies != null:
			temp_flies.get_node("Node2D/firefly1/AnimationPlayer2").play("FadeOut")
			temp_flies.get_node("Node2D/firefly2/AnimationPlayer2").play("FadeOut")
			temp_flies.get_node("Node2D/firefly3/AnimationPlayer2").play("FadeOut")
		if temp_flies2 != null:
			temp_flies2.get_node("firefly1/AnimationPlayer2").play("FadeOut")
			temp_flies2.get_node("firefly2/AnimationPlayer2").play("FadeOut")
			temp_flies2.get_node("firefly3/AnimationPlayer2").play("FadeOut")
	elif get_parent().name == "Main":
		get_owner().find_node("Player").disable_movement()
	get_owner().find_node("CameraFlatWorld").shake()
	$AnimationPlayer2.play("FadeToWhite")
	# $AnimationPlayer.queue("FadeToWhite")
	_audio_controller.stop_ambiance()

func _on_AnimationPlayer_animation_finished(anim_name):
#	if anim_name == "FadeToWhite": # we faded to white so that we can do a scene change
#		get_tree().change_scene("res://Scenes/Main.tscn")
	if anim_name == "EndingCutscene":
		# get_tree().change_scene("res://Scenes/EndingCutscene.tscn")
		var current_scene = get_parent()
		get_tree().get_root().add_child(get_parent().get_next_scene())
		current_scene.queue_free()
	elif anim_name == "EndGame":
		# get_tree().change_scene("res://Scenes/Credits.tscn")
		var current_scene = get_parent()
		get_tree().get_root().add_child(get_parent().get_next_scene())
		current_scene.queue_free()

# bunny drops timemachine scene
func play_ending_cutscene():
	get_owner().get_node("InteractableManager").disable_interactions()
	# get_owner().get_node("DayManager/Day3/Frog/FrogPhysical/Area2D").queue_free() # so we don't show interact icon
	get_owner().get_node("DayManager/Day3/Frog/FrogPhysical/Area2D").position = ConstsEnums.HIDE_VECTOR
	_audio_controller.stop_music()
	_audio_controller.stop_ambiance()
	_audio_controller.fade_out_footsteps()
	$AnimationPlayer.play("EndingCutscene")
	# fade out fireflies, otherwise they shine through the white screen
	var temp_flies = get_parent().get_node("DayManager/Day3/StaticProps/Ricefield_Dirt")
	var temp_flies2 = get_parent().get_node("DayManager/Day3/StaticProps/Bridge_FG")

	if temp_flies != null:
		temp_flies.get_node("firefly1/AnimationPlayer2").play("FadeOut")
		temp_flies.get_node("firefly2/AnimationPlayer2").play("FadeOut")
		temp_flies.get_node("firefly3/AnimationPlayer2").play("FadeOut")
	if temp_flies2 != null:
		temp_flies2.get_node("firefly1/AnimationPlayer2").play("FadeOut")
		temp_flies2.get_node("firefly2/AnimationPlayer2").play("FadeOut")
		temp_flies2.get_node("firefly3/AnimationPlayer2").play("FadeOut")

func end_game():
	# fadeout foodcart lamp
	var temp_cart_light = get_parent().get_node("StaticProps/FoodCart_1/Light2D")
	if temp_cart_light != null:
		temp_cart_light.get_node("AnimationPlayer").play("FadeOut")
	$AnimationPlayer.play("EndGame")
	_audio_controller.stop_ambiance()
	_audio_controller.stop_music()

func _on_AnimationPlayer2_animation_finished(anim_name):
	if anim_name == "FadeToWhite": # we faded to white so that we can do a scene change
		# get_tree().change_scene("res://Scenes/Main.tscn")
		var current_scene = get_parent()
		get_tree().get_root().add_child(get_parent().get_next_scene())
		current_scene.queue_free()
		
