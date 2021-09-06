extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var next_scene = preload("res://Scenes/EndingCutscene.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	if event.is_action_pressed("ui_focus_next"):
		#$SceneManager._on_AnimationPlayer_animation_finished("EndingCutscene")
		#$SceneManager.play_ending_cutscene()
		pass

func get_next_scene():
	return next_scene
