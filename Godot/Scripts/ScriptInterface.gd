extends Node2D


onready var _dialog_manager = get_owner().find_node("DialogManager")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func prepare_dialog(object):
	_dialog_manager.prepare_dialog(object)
