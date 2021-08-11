extends Node2D


var _items = {}

func _init():
	_items = {
#		"time_ticket"	: false,
#		"coin"			: false,
#		"drink"			: false,
#		"peaches"		: true,
#		"seeds"			: false,
#		"seeds_transit"	: false,
#		"veggie"		: true,
#		"ox_favor"		: false,
#		"sauce"			: true,
#		"ending_key"	: false
		"time_ticket"	: false,
		"coin"			: false,
		"drink"			: false,
		"peaches"		: false,
		"seeds"			: false,
		"seeds_transit"	: false,
		"veggie"		: false,
		"ox_favor"		: false,
		"sauce"			: false,
		"ending_key"	: false
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func has_item(item):
	if item == "":
		return false
	if _items.has(item):
		if _items.get(item) == true:
			return true
		else:
			return false
	else :
		return false

func add_item(item):
	if item != "":
		_items[item] = true # just fyi, if item doesn't pre-exist on list, it'll create it
	
func remove_item(item):
	if item != "":
		_items[item] = false
