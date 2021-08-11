extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Idle":
		$Sprite3/Fade_AnimationPlayer.play("Fade_ToWhite")
	pass # Replace with function body.

func _on_Fade_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fade_ToWhite":
		get_tree().change_scene("res://Scenes/Credits.tscn")
