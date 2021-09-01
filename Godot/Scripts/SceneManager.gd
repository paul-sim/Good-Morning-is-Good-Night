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
	if get_parent().name == "FlatWorld1":
		get_owner().find_node("PlayerFlatWorld").disable_movement()
		get_owner().get_node("AudioController").play_ambiance("earthquake.ogg")
		$AnimationPlayer.play("GetTimeMachine")
		$AnimationPlayer.queue("Idle")
	elif get_parent().name == "Main":
		get_owner().find_node("Player").disable_movement()
	get_owner().find_node("CameraFlatWorld").shake()
	$AnimationPlayer.queue("FadeToWhite")
	_audio_controller.stop_ambiance()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeToWhite": # we faded to white so that we can do a scene change
		get_tree().change_scene("res://Scenes/Main.tscn")
	elif anim_name == "EndingCutscene":
		get_tree().change_scene("res://Scenes/EndingCutscene.tscn")
	elif anim_name == "EndGame":
		get_tree().change_scene("res://Scenes/Credits.tscn")

func play_ending_cutscene():
	$AnimationPlayer.play("EndingCutscene")

func end_game():
	$AnimationPlayer.play("EndGame")
