extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var sec = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	sec = delta + sec
	if sec > 2:
		get_tree().change_scene("res://Scenes/Main.tscn")
