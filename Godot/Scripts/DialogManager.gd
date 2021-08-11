extends Node2D

onready var _speech_bubble = $Dialog/SpeechBubble # this is a canvas layer
onready var _label = $Dialog/SpeechBubble/Label
onready var _tween = $Dialog/Tween
onready var _interact_icon = $InteractIcon
onready var _interact_icon_finger = $Finger
onready var _fulfill_node = $FulfillNode
onready var _fulfill_label = $FulfillNode/Fulfill_Label
# onready var _player = get_owner().find_node("Player")
onready var _player
onready var _interactable_manager = get_owner().find_node("InteractableManager")
onready var _sequence_manager = get_owner().find_node("SequenceManager")
onready var _day_manager = get_owner().find_node("DayManager")

var _in_dialog = false
var _dialog_file = "" # string name of json file
var _file_stream = null
var _dialog_text = ""
var _dialog_set = ""
var _index = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	_speech_bubble.position = ConstsEnums.HIDE_VECTOR
	_speech_bubble.visible = true
	_interact_icon.position = ConstsEnums.HIDE_VECTOR
	_interact_icon_finger.position = ConstsEnums.HIDE_VECTOR
	_fulfill_node.position = ConstsEnums.HIDE_VECTOR
	if get_parent().name == "Main":
		_player = get_owner().find_node("Player")
	elif get_parent().name == "FlatWorld1" || get_parent().name == "FlatWorld2":
		_player = get_owner().find_node("PlayerFlatWorld")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func do_next_line():
	if _dialog_file != "":
		if _in_dialog:
			_display_next_line()
		else:
			_player.disable_movement()
			_interactable_manager.dialog_started()
			_load_dialog_file(_dialog_file)
			_set_dialog_set()
			_display_next_line()
			_in_dialog = true

func _load_dialog_file(dialog_file):
	_file_stream = File.new()
	_file_stream.open("res://Dialog/" + dialog_file, _file_stream.READ)
	_dialog_text = parse_json(_file_stream.get_as_text())

func _set_dialog_set():
	match _interactable_manager.get_dialog_set():
		ConstsEnums.DIALOG_SET.INITIAL:
			_dialog_set = "initial"
		ConstsEnums.DIALOG_SET.LOOP:
			_dialog_set = "loop"

func _display_next_line() -> void:
	if _reached_text_end():
		_end_dialog()
		return
	# anim is by itself, no text
	if _dialog_text[_dialog_set][str(_index)]["text"] == "" && _dialog_text[_dialog_set][str(_index)]["animation"] != "":
		_speech_bubble.position += ConstsEnums.HIDE_VECTOR
		_interactable_manager.enable_is_waiting_for_anim()
	# there is text to display
	else:
		_label.percent_visible = 0
		_label.text = _dialog_text[_dialog_set][str(_index)]["text"]
		_reset_label_dimensions()
		var pos = _get_character_pos(_dialog_text[_dialog_set][str(_index)]["name"])
		# pos.y -= ConstsEnums.DIALOG_BUBBLE_FLOAT_DISTANCE # this places the bubble on top of character
		_speech_bubble.position = pos
		_tween.interpolate_property(
			_label, "percent_visible", 0, 1, 0.3,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		_tween.start()
	_play_anim(_dialog_text[_dialog_set][str(_index)]["name"], _dialog_text[_dialog_set][str(_index)]["animation"])
	_index += 1

func _get_character_pos(character_name) -> float:
	if get_parent().name == "FlatWorld1" || get_parent().name == "FlatWorld2":
		return get_parent().find_node(character_name).find_node("SpeechBubblePosition").get_global_position()
	else:
		return (_day_manager.get_current_day_object().find_node(character_name, true, false)).find_node("SpeechBubblePosition").get_global_position()

	# return (get_owner().find_node(character_name, true, false)).find_node("SpeechBubblePosition").get_global_position()

func _play_anim(character_name, animation) -> void:
	if animation == "":
		return
	if character_name == "Player" || character_name == "PlayerFlatWorld":
		pass
	else:
		_day_manager.get_current_day_object().find_node(character_name, true, false).play_animation(animation)
	#(get_owner().find_node(character_name, true, false)).play_animation(animation)

func _reset_label_dimensions() -> void:
	#_label.rect_size = Vector2.ZERO
	_label.rect_min_size = Vector2(1, 1) # in order for control node to update its rect size, we do this weird thing where we fidget with a property for everything else to update
	_label.rect_min_size = Vector2.ZERO
	_label.margin_bottom = 0
	_label.margin_left = 0
	_label.margin_right = 0
	_label.margin_top = 0

func _reset_dialog():
	_speech_bubble.position += ConstsEnums.HIDE_VECTOR
	_in_dialog = false
	# _dialog_file = ""
	_file_stream.close()
	_dialog_text = ""
	_index = 1

func _reached_text_end() -> bool:
	if _index > _dialog_text[_dialog_set].size():
		return true
	else:
		return false

func _end_dialog() -> void:
	_forward_dialog_tag()
	_reset_dialog()
	_player.enable_movement()
	_interactable_manager.dialog_finished()

func _forward_dialog_tag() -> void:
	if _dialog_text["tag"] != "":
		_sequence_manager.process_tag(_dialog_text["tag"])

func set_dialog_file(dialog_file) -> void:
	_dialog_file = dialog_file

func get_dialog_file() -> String:
	return _dialog_file

func show_interact_icon(current_interactable):
	if current_interactable.get_item_fulfill():
		if current_interactable.get_dont_show_fulfill():
			_interact_icon.position = current_interactable.get_speech_bubble_position().get_global_position()
		else:
			if current_interactable.name == "VendingMachine":
				_fulfill_label.text = "insert coins"
			elif current_interactable.name == "Boxes":
				_fulfill_label.text = "search boxes"
			elif current_interactable.name == "Monkey":
				_fulfill_label.text = "offer drink"
			elif current_interactable.name == "FertileSoil" && (_day_manager.get_current_day_object().get_day() == ConstsEnums.DAY.ONE):
				_fulfill_label.text = "sow seeds"
			elif current_interactable.name == "FertileSoil" && (_day_manager.get_current_day_object().get_day() == ConstsEnums.DAY.THREE):
				_fulfill_label.text = "harvest vegetable"
			elif current_interactable.name == "Window":
				_fulfill_label.text = "close windows"
			elif current_interactable.name == "OxMom":
				_fulfill_label.text = "congratulate her"
			elif current_interactable.name == "Turtle":
				_fulfill_label.text = "give ingredients"
			_fulfill_node.position = current_interactable.get_speech_bubble_position().get_global_position()
	else:
		if current_interactable.get_interact_icon_type() == ConstsEnums.INTERACT_ICON_TYPE.FINGER:
			_interact_icon_finger.position = current_interactable.get_speech_bubble_position().get_global_position()
		else: # dialog icon type is a dialog bubble image
			_interact_icon.position = current_interactable.get_speech_bubble_position().get_global_position()

func hide_interact_icon():
	_interact_icon.position = ConstsEnums.HIDE_VECTOR
	_interact_icon_finger.position = ConstsEnums.HIDE_VECTOR
	_fulfill_node.position = ConstsEnums.HIDE_VECTOR
