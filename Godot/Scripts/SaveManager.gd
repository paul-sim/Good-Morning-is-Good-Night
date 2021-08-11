extends Node2D


const INTERACTABLE_CLASS = preload("res://Scripts/Interactable.gd") # this const is not declared in constsEnums file because the preload function requires a certain script execution orer in order to not have an error

var _interactables_day1 = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func save_day_state(current_day_object):
	var interactables
	match current_day_object.name:
		"Day1":
			interactables = _interactables_day1
	
	interactables.clear()
	for c in current_day_object.get_children():
		if c is INTERACTABLE_CLASS:
			var interactable_state = {
				"name" : c.name,
				"dialog_file" : c.get_dialog_file(),
				"item_wanted" : c.get_item_wanted(),
				"item_give" : c.get_item_give(),
				"current_dialog_set" : c.get_current_dialog_set(),
				"dialog_read" : c.get_dialog_read(),
				"item_fulfill" : c.get_item_fulfill()
			}
			interactables.append(interactable_state)

func load_day_state(new_day_object):
	var interactables
	match new_day_object.name:
		"Day1":
			interactables = _interactables_day1
	for i in interactables:
		var c = new_day_object.get_node(i["name"])
		if c != null:
			c.set_dialog_file(i["dialog_file"])
			c.set_item_wanted(i["item_wanted"])
			c.set_item_give(i["item_give"])
			c.set_current_dialog_set(i["current_dialog_set"])
			c.set_dialog_read(i["dialog_read"])
			c.set_item_fulfill(i["item_fulfill"])


#func load_interactable_state(day, interactable):
#	var _interactables
#	match day:
#		"Day1":
#			_interactables = _interactables_day1
