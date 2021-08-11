extends Node2D

var _day1_preload = preload("res://Scenes/Day1.tscn")
onready var _save_manager = get_owner().find_node("SaveManager")

var _current_day = ConstsEnums.DAY.ZERO
var _current_day_object = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func entered_door(area_name):
	if area_name == "Forward_Area2D":
		create_day(_current_day)

func create_day(day):
	save_current_day_state() # save current day state before we create a new one
	destroy_current_day()
	# create new day
	match day:
		ConstsEnums.DAY.ONE:
			_current_day = ConstsEnums.DAY.ONE
			_current_day_object = _day1_preload.instance()
			_current_day_object.position = Vector2.ZERO
			add_child(_current_day_object) 
			_save_manager.load_day_state(_current_day_object) # this must be called after day object has been added to scene. otherwise, the interactable object's _ready function gets called after state's been loaded and overrides the dialog file name

func save_current_day_state():
	if _current_day_object != null:
		_save_manager.save_day_state(_current_day_object)

func destroy_current_day():
	if _current_day_object != null:
		remove_child(_current_day_object) # queue_free is auto called in the Day.gd _exit_tree() method
		#_current_day_object.queue_free() # this has problems.. i think it's because a new day is created on the same frame while this method requires frame to end
		_current_day_object = null

