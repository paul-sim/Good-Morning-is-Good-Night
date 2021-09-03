extends Node2D


onready var _sky = get_owner().find_node("Sky")
onready var _forward_area2D = $DoorPhysical/Forward_Area2D
onready var _backward_area2D = $DoorPhysical/Backward_Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Forward_Area2D_area_entered(area):
	hide_portals()
	_sky.transition_to_day()
	$DoorPhysical/DoorSprite/AnimationPlayer.play("OpenForward")
	get_parent().get_node("AudioController").play_door_SFX()

func _on_Backward_Area2D_area_entered(area):
	hide_portals()
	_sky.transition_to_night()
	$DoorPhysical/DoorSprite/AnimationPlayer.play("OpenBackward")
	get_parent().get_node("AudioController").play_door_SFX()

func hide_portals():
	_forward_area2D.position = ConstsEnums.HIDE_VECTOR
	_backward_area2D.position = ConstsEnums.HIDE_VECTOR

func return_portals():
	_forward_area2D.position = Vector2.ZERO
	_backward_area2D.position = Vector2.ZERO
