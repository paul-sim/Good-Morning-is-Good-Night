extends KinematicBody2D

const INTERACTABLE_CLASS = preload("res://Scripts/Interactable.gd") # this const is not declared in constsEnums file because the preload function requires a certain script execution orer in order to not have an error
const DOOR_CLASS = preload("res://Scripts/Door.gd")

onready var _camera = get_owner().find_node("Camera2D")
onready var _interactable_manager = get_owner().find_node("InteractableManager")
onready var _door = get_owner().find_node("FinalDoor")
onready var _audio_controller = get_owner().find_node("AudioController")
onready var _anim_player = $Sprite/AnimationPlayer
onready var _sprite = $Sprite

const ACCELERATION = 5000 #500
const MAX_SPEED = 400
#const MAX_SPEED = 2000
const FRICTION = 8000 #700

export(ConstsEnums.WORLD) var _in_world_type = ConstsEnums.WORLD.UNASSIGNED

var _velocity = Vector2.ZERO
var _last_run_direction = ConstsEnums.DIRECTION.NEUTRAL
var _previous_position = Vector2.ZERO
var _is_moving = false
var _move_enabled = true
var _is_opening_door = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_audio_controller.play_ambiance("night_ambiance.ogg")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	
	if _move_enabled == false:
		_audio_controller.stop_footstep()
		return

	if _is_opening_door:
		pass
		return

	var input_vector = Vector2.ZERO

	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector = input_vector.normalized()

	if (input_vector != Vector2.ZERO):
		if _previous_position.x == position.x : # check if player is walking into a wall
			_anim_player.play("Idle")
			_audio_controller.stop_footstep()
		elif (input_vector.x > 0):
			_sprite.flip_h = false
			_anim_player.play("Run")
			_last_run_direction = ConstsEnums.DIRECTION.RIGHT
			_audio_controller.play_footstep()
		elif (input_vector.x < 0):
			_sprite.flip_h = true
			_anim_player.play("Run")
			_last_run_direction = ConstsEnums.DIRECTION.LEFT
			_audio_controller.play_footstep()
		else:
			_audio_controller.stop_footstep()
		_velocity = _velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		_previous_position = position
	else: 
		match _last_run_direction:
			ConstsEnums.DIRECTION.RIGHT:
				_sprite.flip_h = false
				_anim_player.play("Idle")
				_audio_controller.stop_footstep()
			ConstsEnums.DIRECTION.LEFT:
				_sprite.flip_h = true
				_anim_player.play("Idle")
				_audio_controller.stop_footstep()
			_:
				_anim_player.play("Idle")
				_audio_controller.stop_footstep()
		_velocity = _velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	_velocity = move_and_slide(_velocity)

func get_is_moving():
	return _is_moving

func _on_Player_Area2D_area_entered(area):
	var temp = area.get_parent()
	if temp is INTERACTABLE_CLASS:
		_interactable_manager.area_entered(area)
	elif temp is DOOR_CLASS:
		if ! _is_opening_door:
			_initiate_door_open(area.name)
			#_day_manager.entered_door(area.name)

func _on_Player_Area2D_area_exited(area):
	_interactable_manager.area_exited(area)

func disable_movement() -> void:
	_move_enabled = false
	_anim_player.play("Idle")
	# _velocity = _velocity.move_toward(Vector2.ZERO, FRICTION) # if we don't do this, player will slide a bit when they finish a conversation

func enable_movement() -> void:
	_move_enabled = true

func _initiate_door_open(area_name):
	_camera.zoom_door()
	# _anim_player.play("OpenDoor")
	_is_opening_door = true

func play_anim(anim):
	if anim == "FinalDoorExit":
		_move_enabled = false
		_anim_player.play(anim)
		
