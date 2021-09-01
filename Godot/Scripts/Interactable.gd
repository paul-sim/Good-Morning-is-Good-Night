extends Node2D

# onready var _interactable_manager = get_owner().find_node("InteractableManager", true, false)
# onready var _interactable_manager = get_parent().get_parent().get_parent().get_node("InteractableManager") # get_owner() only gets you the node at the top of this scene (and not to Main node). so just do something hacky to get to Main node
var _interactable_manager = null
# onready var _player = null
onready var _sprite = find_node("Sprite")
# onready var _interact_icon = find_node("InteractSprite")
# onready var _interact_icon = get_owner().find_node("InteractIcon")
onready var _anim_player = get_node("AnimationPlayer")
export(ConstsEnums.INTERACTABLE_TYPE) var _interactable_type = ConstsEnums.INTERACTABLE_TYPE.DIALOG
export(ConstsEnums.INTERACT_ICON_TYPE) var _interactable_icon_type = ConstsEnums.INTERACT_ICON_TYPE.DIALOG

var _dialog_file : String
export var _item_wanted : String
export var _item_give: String
var _current_dialog_set = ConstsEnums.DIALOG_SET.INITIAL
var _dialog_read = false # past tense "read". a player may talk to the key giver first before talking to key receiver. in that case, talking to key receiver will go straight into the new dialog without the player ever seeing their first dialog. so we use this variable to check if we need to play the first dialog first before playing the next dialog
var _item_fulfill = false
var _item_fulfilled = false
export var _dont_show_fulfill = false # for NPCs that don't have item wanted but have item to give. set to true for them

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().name == "FlatWorld1":
		_interactable_manager = get_parent().find_node("InteractableManager")
	elif get_parent().name == "FlatWorld2":
		_interactable_manager = get_parent().find_node("InteractableManager")
	else:
		_interactable_manager = get_parent().get_parent().get_parent().get_node("InteractableManager") # get_owner() only gets you the node at the top of this scene (and not to Main node). so just do something hacky to get to Main node
	hide_interact_icon()
	# any assignments here will be overrided by SaveManager's load_day_state() function
	_dialog_file = get_parent().name + "_" + self.name + ".json"
#	if get_owner().name == "FlatWorld1":
#		_player = get_parent().get_node("PlayerFlatWorld")
#	else: # assume you're in circle world
#		_player = get_parent().get_parent().get_parent().get_node("Player")
	
	# all interactables that don't have item wanted but have item to give are hard coded to be fulfilled on initial dialog
	if self.name == "Boxes":
		_item_fulfill = true
	elif self.name == "Crane" && get_parent().name == "Day2": # crane can give you seeds only on day2
		_item_fulfill = true
	elif self.name == "FertileSoil" && get_parent().name == "Day3": # in truth, fertile soil on day3 doesn't need an "item wanted" because it's physically hidden anyway until the prereqs are met
		self.position = ConstsEnums.HIDE_VECTOR # fertile soil is hidden until seed is sown
		_item_fulfill = true
	elif self.name == "Window":
		_item_fulfill = true
	elif self.name == "Turtle" && get_parent().name == "FlatWorld1":
		_item_fulfill = true
	elif self.name == "Turtle" && get_parent().name == "FlatWorld2":
		_item_fulfill = true

func show_interact_icon() -> void:
	# _interact_icon.position = $CranePhysical/SpeechBubblePosition.get_global_position()
	# _interact_icon.visible = true
#	if ! _item_fulfill:
#		_interact_icon.visible = true
#	else:
#		print("hello")
	#_interact_icon.position = get_parent().position
	#_interact_icon.position.y -= ConstsEnums.FLOAT_DISTANCE # make icon float above npc/thing
	pass

func hide_interact_icon() -> void:
	#_interact_icon.position += ConstsEnums.HIDE_VECTOR
	# _interact_icon.visible = false
	# _interact_icon.position = ConstsEnums.HIDE_VECTOR
	pass

func get_dialog_file() -> String:
	return _dialog_file

func set_dialog_file(dialog_file):
	_dialog_file = dialog_file

func get_interactable_type():
	return _interactable_type

func get_current_dialog_set():
	return _current_dialog_set
	
func set_current_dialog_set(dialog_set):
	_current_dialog_set = dialog_set

func play_animation(animation) -> void:
	_anim_player.play(animation)
		# get_node("AnimationPlayer").play(animation)
	#_anim_player.play(animation)

func stop_animation() -> void:
	_anim_player.stop()

func _on_AnimationPlayer_animation_finished(anim_name):
	# get_owner().find_node("InteractableManager").animation_finished()
	_interactable_manager.animation_finished()

func get_dialog_read():
	return _dialog_read

func set_dialog_read(dialog_read):
	_dialog_read = dialog_read

func get_item_wanted():
	return _item_wanted

func set_item_wanted(item_wanted):
	_item_wanted = item_wanted
	
func get_item_give():
	return _item_give

func set_item_give(item_give):
	_item_give = item_give

func set_item_fulfill(item_fulfill):
	_item_fulfill = item_fulfill
	
func get_item_fulfill():
	return _item_fulfill

#func set_item_fulfilled(item_fulfilled):
#	_item_fulfilled = item_fulfilled
#
#func get_item_fulfilled():
#	return _item_fulfilled

func get_speech_bubble_position():
	return find_node("SpeechBubblePosition")

func get_dont_show_fulfill():
	return _dont_show_fulfill

func get_sprite():
	return _sprite

func set_sprite_texture(sprite_texture):
	_sprite.set_texture(load("res://Sprites/" + sprite_texture))

func get_interact_icon_type():
	return _interactable_icon_type

func get_area2D():
	return find_node("Area2D")
