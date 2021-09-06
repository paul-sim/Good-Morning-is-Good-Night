extends Node2D

var next_scene = preload("res://Scenes/Credits.tscn").instance()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# $AudioController.play_music_abruptly("turtle_end.ogg")
	pass # Replace with function body.

func get_next_scene():
	return next_scene
