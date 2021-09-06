extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var next_scene = preload("res://Scenes/Main.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_next_scene():
	return next_scene

func _unhandled_input(event):
	if event.is_action_pressed("ui_focus_next"):
		#$SceneManager._on_AnimationPlayer2_animation_finished("FadeToWhite")
		#$SceneManager.change_scene("Main.tscn")
		pass
