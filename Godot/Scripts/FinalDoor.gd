extends Node2D

onready var _player = get_parent().get_node("PlayerFlatWorld")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# entered final door
func _on_Area2D_area_entered(area):
	_player.play_anim("FinalDoorExit")
	get_parent().get_node("AudioController").play_door_SFX()
	get_parent().get_node("AudioController/SFX/Door_AnimationPlayer").play("FadeOut")
	get_node("Sprite/AnimationPlayer").play("OpenDoor")
	get_parent().get_node("SceneManager").end_game()
