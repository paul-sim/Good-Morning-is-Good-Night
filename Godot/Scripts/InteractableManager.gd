extends Node2D

#onready var _player = get_owner().find_node("Player")
onready var _player = null
onready var _dialog_manager = get_owner().find_node("DialogManager")
onready var _door_manager = get_owner().find_node("DoorManager")
onready var _scene_manager = get_owner().find_node("SceneManager")
onready var _inventory = get_owner().find_node("Inventory")
onready var _audio_controller = get_owner().find_node("AudioController")

var _interactables = []
# var _closest_interactable_type = ConstsEnums.INTERACTABLE_TYPE.UNASSIGNED
var _current_interactable = null
var _is_interacting = false # keeps from modifying which interactables are in player's area
var _is_waiting_for_anim = false # some anims must complete the spacebar can become functional again
var _forced_interactable = false
var _interactable_disabled = false # when fading to white in flatworld1, nothing should be interactable

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().name == "Main":
		_player = get_owner().find_node("Player")
	elif get_parent().name == "FlatWorld1" || get_parent().name == "FlatWorld2":
		_player = get_owner().find_node("PlayerFlatWorld")

func _unhandled_input(event):
	if ! _interactable_disabled:
		if event.is_action_pressed("ui_accept") && _interactables.size() > 0 && ! _is_waiting_for_anim:
			_interact()
		
func area_entered(area) -> void:
	if _is_interacting: # if player is currently interacting, don't switch who they can interact with. this might happen if there's an anim where a sprite with area2D enters the player's area2D
		return
	if get_parent().name == "Main":
		_interactables.append(area.get_parent().get_parent())
	elif get_parent().name == "FlatWorld1" || get_parent().name == "FlatWorld2":
		_interactables.append(area.get_parent())
	deactivate_all_interactables()
	activate_closest_interactable()

func area_exited(area) -> void:
	if _is_interacting:
		return
	deactivate_all_interactables()
	if get_parent().name == "Main":
		_interactables.erase(area.get_parent().get_parent())
	elif get_parent().name == "FlatWorld1" || get_parent().name == "FlatWorld2":
		_interactables.erase(area.get_parent())
	activate_closest_interactable()

func _interact() -> void:
	if _current_interactable.get_interactable_type() == ConstsEnums.INTERACTABLE_TYPE.DIALOG:
		_is_interacting = true
		_dialog_manager.do_next_line()
		_audio_controller.play_SFX("dialog_continue.ogg")
	elif _current_interactable.get_interactable_type() == ConstsEnums.INTERACTABLE_TYPE.DOOR:
		_is_interacting = true
		_door_manager.open_door()
	else:
		pass

func deactivate_all_interactables() -> void:
	_dialog_manager.set_dialog_file("")
	_current_interactable = null
	hide_interactable_icon()

func activate_closest_interactable() -> void:
	if _interactables.size() == 0: # no interactables in range
		return
	### determine closest interactable
	var closest_interactable = null
	var closest_distance = 10000 # large arbitrary number
	for i in _interactables:
		var temp_distance = abs(_player.position.x - i.position.x)
		if temp_distance < closest_distance:
			closest_interactable = i
			closest_distance = temp_distance
	### activate closest interactable
	_current_interactable = closest_interactable
	if _current_interactable.get_interactable_type() == ConstsEnums.INTERACTABLE_TYPE.DIALOG:
		if _current_interactable.get_dialog_read(): # we only use fulfill dialog if initial dialog has been seen by player
			if _inventory.has_item(_current_interactable.get_item_wanted()):
				if (! ("fulfill" in _current_interactable.get_dialog_file())): # if we already added "fulfill" to dialog file name, don't add it again
					var new_dialog_file = _current_interactable.get_dialog_file()
					new_dialog_file = new_dialog_file.insert(new_dialog_file.length() - 5, "_fulfill") # if player has item to give npc, then change dialog file to the fulfill dialog file. the "5" here is the words ".json" so insert "fulfill" just before that
					if "_alt" in new_dialog_file: # this is special case with ox mom
						new_dialog_file = "Day3_OxMom_fulfill.json"
					_current_interactable.set_dialog_file(new_dialog_file)
					#_current_interactable.set_dialog_file(_current_interactable.get_dialog_file() + "_fulfill") # if player has item to give npc, then change dialog file to the fulfill dialog file
					_current_interactable.set_current_dialog_set(ConstsEnums.DIALOG_SET.INITIAL)
					_current_interactable.set_item_fulfill(true)
		_dialog_manager.set_dialog_file(_current_interactable.get_dialog_file())
	elif _current_interactable.get_interactable_type() == ConstsEnums.INTERACTABLE_TYPE.DOOR:
		_door_manager.set_current_door(_current_interactable)
	# _current_interactable.show_interact_icon()
	_dialog_manager.show_interact_icon(_current_interactable)

func hide_interactable_icon() -> void:
	_dialog_manager.hide_interact_icon()
#	for i in _interactables:
		# i.hide_interact_icon() # technically, there should only be one whose icon is showing

func force_interactable(interactable) -> void:
	_forced_interactable = true
	_interactables.append(interactable)
	_current_interactable = interactable
	if _current_interactable.get_interactable_type() == ConstsEnums.INTERACTABLE_TYPE.DIALOG:
		_dialog_manager.set_dialog_file(_current_interactable.get_dialog_file())
		_interact()

func dialog_started() -> void:
	hide_interactable_icon()

func door_started() -> void:
	hide_interactable_icon()

func dialog_finished() -> void:
	_advance_dialog_set()
	item_exchange()
	#_unlock_interactable_keys(_current_interactable, ConstsEnums.INTERACTABLE_TYPE.DIALOG)
	_current_interactable.set_dialog_read(true)
	_remove_forced_interactable() # checks if interaction was forced (e.g. interactable may be distant or far away)
	deactivate_all_interactables()
	activate_closest_interactable()
	_is_interacting = false

func walk_through_door_finished() -> void:
	deactivate_all_interactables()
	activate_closest_interactable()
	animation_finished()
	_is_interacting = false

func animation_finished() -> void:
	if _is_waiting_for_anim:
		_is_waiting_for_anim = false
		if _current_interactable.get_interactable_type() == ConstsEnums.INTERACTABLE_TYPE.DIALOG:
			_interact() # finished lone anim within dialog so continue next line automatically

func _remove_forced_interactable() -> void:
	if _forced_interactable:
		# this interaction was forced. normally we remove an interactable from the interactable list when we exit its area2D but since there is no area2D here, we manually erase it from the interactable list
		_interactables.erase(_current_interactable)
		_current_interactable.queue_free()
		_current_interactable = null
		_forced_interactable = false

func enable_is_waiting_for_anim() -> void:
	_is_waiting_for_anim = true

func disable_interactions() -> void:
	_interactable_disabled = true

func enable_interactions() -> void:
	_interactable_disabled = false

func get_dialog_set():
	return _current_interactable.get_current_dialog_set()

func _advance_dialog_set():
	if _current_interactable.get_current_dialog_set() == ConstsEnums.DIALOG_SET.INITIAL:
		_current_interactable.set_current_dialog_set(ConstsEnums.DIALOG_SET.LOOP) # after initial conversation, default to a dialog set that can be looped over and over again

# called at the end of a dialog
func item_exchange():
	if _current_interactable.get_item_fulfill() == true: # should only be true if exchange can happen
		if _current_interactable.get_item_give() != "":
			_inventory.add_item(_current_interactable.get_item_give()) # give item to player
		_inventory.remove_item(_current_interactable.get_item_wanted()) # remove npc's wanted item from player's inventory
		_current_interactable.set_item_wanted("")
		_current_interactable.set_item_give("")
		_current_interactable.set_item_fulfill(false) # item fulfill should only be set to true once for giving item to player then goes to false
		# do butterfly effect
		_butterfly_effect()

# when you do something for an NPC, let it have effect on subsequent days
func _butterfly_effect():
	if _current_interactable.name == "Frog" && get_parent().name == "FlatWorld1": # flatworld1 when this triggers
		# disable player controls
		_player.disable_movement()
		disable_interactions()
		_dialog_manager.destroy_interact_icon() # so that players won't see the interact icon
		# change scene to circle world
		_scene_manager.change_scene("Main.tscn")
	elif _current_interactable.name == "Boxes": # day 1/2/3 when this triggers
		# disable box machine
		# _current_interactable.find_node("Area2D").queue_free()
		get_parent().get_node("DayManager/Day1/Boxes/BoxPhysical/Area2D").queue_free()
		get_parent().get_node("DayManager/Day2/Boxes/BoxPhysical/Area2D").queue_free()
		get_parent().get_node("DayManager/Day3/Boxes/BoxPhysical/Area2D").queue_free()
		_player.play_animation("ObtainCoin")
		_audio_controller.play_SFX("item_obtain_small.ogg")
		# force_interactable(get_owner().get_node("DayManager/Day3/ForcedInteractablePeach"))
	elif _current_interactable.name == "VendingMachine": # day2 when this triggers
		var day3_vending_machine = get_parent().get_node("DayManager/Day3/VendingMachine")
		_current_interactable.set_dialog_file("Day2_VendingMachine_fulfilled.json") # no need to change dialog set to inital since vending machine has same lines for both inital and loop lines
		day3_vending_machine.set_dialog_file("Day3_VendingMachine_fulfilled.json")
		_player.play_animation("ObtainDrink")
		_audio_controller.play_SFX("item_obtain_small.ogg")
	elif _current_interactable.name == "Monkey": # day1 when this triggers
		var day2_monkey = get_parent().get_node("DayManager/Day2/Monkey")
		var day3_monkey = get_parent().get_node("DayManager/Day3/Monkey")
		day2_monkey.play_animation("FullHappy")
		day2_monkey.set_dialog_file("Day2_Monkey_fulfilled.json")
		day2_monkey.set_current_dialog_set(ConstsEnums.DIALOG_SET.INITIAL)
		day3_monkey.play_animation("FullHappy")
		day3_monkey.set_dialog_file("Day3_Monkey_fulfilled.json")
		day3_monkey.set_current_dialog_set(ConstsEnums.DIALOG_SET.INITIAL)
		get_parent().get_node("DayManager/Day1/StaticProps/peach_box").modulate.a = 0
		get_parent().get_node("DayManager/Day2/StaticProps/peach_box").modulate.a = 0
		get_parent().get_node("DayManager/Day3/StaticProps/peach_box").modulate.a = 0
		_player.play_animation("ObtainPeaches")
		_audio_controller.play_SFX("item_obtain_big.ogg")
	elif _current_interactable.name == "Crane": # day2 when this triggers
		var day3_crane = get_parent().get_node("DayManager/Day3/Crane")
		day3_crane.set_dialog_file("Day3_Crane_fulfilled.json")
		day3_crane.set_current_dialog_set(ConstsEnums.DIALOG_SET.INITIAL)
		_player.play_animation("ObtainSeeds")
		_audio_controller.play_SFX("item_obtain_small.ogg")
	elif _current_interactable.name == "FertileSoil" && _current_interactable.get_parent().name == "Day1": # day1 when this triggers
		_current_interactable.get_node("FertileSoilPhysical/Area2D").queue_free()
		get_parent().get_node("DayManager/Day1/StaticProps/rice_plant_1").modulate.a = 1
		get_parent().get_node("DayManager/Day2/StaticProps/rice_plant_2").modulate.a = 1
		get_parent().get_node("DayManager/Day3/StaticProps/rice_plant_3").modulate.a = 1
		get_parent().get_node("DayManager/Day3/FertileSoil").position = Vector2.ZERO # fertile soil was hidden, now we bring it in
	elif _current_interactable.name == "FertileSoil" && _current_interactable.get_parent().name == "Day3": # day1 when this triggers
		_current_interactable.queue_free()
		get_parent().get_node("DayManager/Day3/StaticProps/rice_plant_3").modulate.a = 0
		_player.play_animation("ObtainVeggie")
		_audio_controller.play_SFX("item_obtain_big.ogg")
	elif _current_interactable.name == "Window": # day2 trigger
		var day3_ox_mom = get_parent().get_node("DayManager/Day3/OxMom")
		day3_ox_mom.set_dialog_file("Day3_OxMom_alt.json") # logically need an alt dialog for story to make sense
		_current_interactable.queue_free()
	elif _current_interactable.name == "OxMom": # day3 trigger
		_player.play_animation("ObtainSauce")
		_audio_controller.play_SFX("item_obtain_big.ogg")
	elif _current_interactable.name == "Turtle" && get_parent().name == "FlatWorld1": # triggers in flatworld1
		var frog = get_parent().get_node("Frog")
		frog.set_dialog_read(true) # skip any initial dialog, go straight to important dialog
	elif _current_interactable.name == "Turtle" && get_parent().name == "FlatWorld2":
		get_parent().get_node("CameraFlatWorld").camera_end_frame()
		get_parent().get_node("Walls/StaticBody2D2").position.x -= 1100
		
