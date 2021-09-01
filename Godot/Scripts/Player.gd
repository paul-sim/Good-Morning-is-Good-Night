extends Node2D

const INTERACTABLE_CLASS = preload("res://Scripts/Interactable.gd") # this const is not declared in constsEnums file because the preload function requires a certain script execution orer in order to not have an error
const DOOR_CLASS = preload("res://Scripts/Door.gd")

onready var _camera = get_owner().find_node("Camera2D")
onready var _interactable_manager = get_owner().find_node("InteractableManager")
onready var _day_manager = get_owner().find_node("DayManager")
onready var _door = get_owner().find_node("Door")
onready var _audio_controller = get_owner().find_node("AudioController")
onready var _anim_player = $PlayerPhysical/KinematicBody2D/Sprite/AnimationPlayer
onready var _item_anim_player = $PlayerPhysical/Item/Item_AnimationPlayer
onready var _sprite = $PlayerPhysical/KinematicBody2D/Sprite
onready var _item_sprite = $PlayerPhysical/Item

const ACCELERATION = 2000 #500
const MAX_SPEED = 50
const FRICTION = 2000 #700

# export(ConstsEnums.WORLD) var _in_world_type = ConstsEnums.WORLD.UNASSIGNED

var _velocity = Vector2.ZERO
var _last_run_direction = ConstsEnums.DIRECTION.NEUTRAL
var _previous_position = 0
var _is_moving = false
var _move_enabled = true
var _is_opening_door = false
var _door_open_direction # should be 1 or -1
var _stop_right_direction = false
var _stop_left_direction = false
var _previous_rotation_degrees = 0
var _timer = 0
var _thinking_played = false 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# initialize_for_world_type()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#
#func initialize_for_world_type():
#	if _in_world_type == ConstsEnums.WORLD.FLAT:
#		self.rotation_degrees = 0
#		$PlayerPhysical.position = Vector2.ZERO
#	else: # you're in circle world
#		# the player scene is already setup for circle world so no need to custom initialize it
#		pass

func _process(delta):
	# check inventory every few seconds
#	_timer += delta
#	if _timer >= 5 && _thinking_played == false:
#		_timer = 0
#		# check inventory
#		var inventory = $Inventory
#		if inventory.has_item("peaches"):
#			if inventory.has_item("veggie"):
#				if inventory.has_item("sauce"):
#					_thinking_played = true
#					$PlayerPhysical/thinking/Thinking_AnimationPlayer.play("Thinking")
#
	pass

func _physics_process(delta):
	
	if _move_enabled == false:
		_audio_controller.stop_footstep()
		return
		
	if _is_opening_door:
		rotation_degrees += ConstsEnums.PLAYER_ROTATE_DOOR_INCREMENT * delta * ConstsEnums.PLAYER_SPEED_FACTOR * _door_open_direction
		return
	
	var input_vector = Vector2.ZERO

	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector = input_vector.normalized()

	if (input_vector != Vector2.ZERO):
#		if _previous_rotation_degrees == self.rotation_degrees: # check if player is walking into a wall
#			_anim_player.play("Idle")
		if (input_vector.x > 0):
			if ! _stop_right_direction: # check that we aren't ignoring the right key input for when player is up against a fence
				_sprite.flip_h = false
				_anim_player.play("Run")
				rotation_degrees += ConstsEnums.PLAYER_ROTATE_INCREMENT * delta * ConstsEnums.PLAYER_SPEED_FACTOR
				_last_run_direction = ConstsEnums.DIRECTION.RIGHT
				_audio_controller.play_footstep()
		elif (input_vector.x < 0):
			if ! _stop_left_direction:
				_sprite.flip_h = true
				_anim_player.play("Run")
				rotation_degrees -= ConstsEnums.PLAYER_ROTATE_INCREMENT * delta * ConstsEnums.PLAYER_SPEED_FACTOR
				_last_run_direction = ConstsEnums.DIRECTION.LEFT
				_audio_controller.play_footstep()
		else: # player is pressing up or down
			_audio_controller.stop_footstep()
		#_previous_rotation_degrees = self.rotation_degrees
	else: 
		match _last_run_direction:
			ConstsEnums.DIRECTION.RIGHT:
				_sprite.flip_h = false
				_anim_player.play("Idle")
			ConstsEnums.DIRECTION.LEFT:
				_sprite.flip_h = true
				_anim_player.play("Idle")
			_:
				_anim_player.play("Idle")
		_audio_controller.stop_footstep()

func get_is_moving():
	return _is_moving

func _on_Area2D_area_entered(area):
	var temp = area.get_parent().get_parent()
	if temp is INTERACTABLE_CLASS:
		_interactable_manager.area_entered(area)
	elif temp is DOOR_CLASS:
		if ! _is_opening_door:
			_initiate_door_open(area.name)
			_day_manager.entered_door(area.name)

func _on_Player_Area2D_area_exited(area):
	_interactable_manager.area_exited(area)

func disable_movement() -> void:
	_move_enabled = false
	_anim_player.play("Idle")
	# _velocity = _velocity.move_toward(Vector2.ZERO, FRICTION) # if we don't do this, player will slide a bit when they finish a conversation

func enable_movement() -> void:
	_move_enabled = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "OpenDoor":
		_is_opening_door = false # player has finished walking through door
		_camera.zoom_default()
		_door.return_portals()
#	else:
#		_interactable_manager.animation_finished()

func _initiate_door_open(area_name):
	if area_name == "Forward_Area2D":
		_door_open_direction = 1
	elif area_name == "Backward_Area2D":
		_door_open_direction = -1
	_camera.zoom_door()
	_anim_player.play("OpenDoor")
	_is_opening_door = true

func get_rotation_degrees():
	return self.rotation_degrees

# when player is up against the fence, we ignore inputs that allow them to move past the fence
func set_stop_right_direction(some_bool):
	_stop_right_direction = some_bool
	_anim_player.play("Idle")
	
func set_stop_left_direction(some_bool):
	_stop_left_direction = some_bool
	_anim_player.play("Idle")

func play_animation(animation):
	if animation == "ObtainDrink":
		_item_sprite.set_texture(load("res://Sprites/Props/can.png"))
		# _item_sprite.rotation_degrees = 0 - self.rotation_degrees
		_item_anim_player.play("ObtainItem") # separate animation player for item animations otherwise main animation player overrides its animation
	elif animation == "ObtainCoin":
		_item_sprite.set_texture(load("res://Sprites/Props/coin.png"))
		# _item_sprite.rotation_degrees = 0 - self.rotation_degrees
		_item_anim_player.play("ObtainItem")
	elif animation == "ObtainPeaches":
		_item_sprite.set_texture(load("res://Sprites/Props/peach_box.png"))
		# _item_sprite.rotation_degrees = 0 - self.rotation_degrees
		_item_anim_player.play("ObtainItem")
	elif animation == "ObtainSeeds":
		_item_sprite.set_texture(load("res://Sprites/Props/rice_seed.png"))
		# _item_sprite.rotation_degrees = 0 - self.rotation_degrees
		_item_anim_player.play("ObtainItem")
	elif animation == "ObtainVeggie":
		_item_sprite.set_texture(load("res://Sprites/Props/rice_plant_3.png"))
		# _item_sprite.rotation_degrees = 0 - self.rotation_degrees
		_item_anim_player.play("ObtainItem")
	elif animation == "ObtainSauce":
		_item_sprite.set_texture(load("res://Sprites/Props/sauce.png"))
		# _item_sprite.rotation_degrees = 0 - self.rotation_degrees
		_item_anim_player.play("ObtainItem")
	else:
		_anim_player.play(animation)

func _on_Item_AnimationPlayer_animation_finished(anim_name):
	_item_anim_player.play("Idle")

func check_lose_time_machine():
	var inventory = $Inventory
	if inventory.has_item("peaches"):
		if inventory.has_item("veggie"):
			if inventory.has_item("sauce"):
				# play cutscene
				_move_enabled = false
				_anim_player.play("Idle")
				get_parent().get_node("SceneManager").play_ending_cutscene()

func has_all_key_items():
	var inventory = $Inventory
	if inventory.has_item("peaches"):
		if inventory.has_item("veggie"):
			if inventory.has_item("sauce"):
				return true
	return false

func play_thinking_animation():
	$PlayerPhysical/thinking/Thinking_AnimationPlayer.play("Thinking")
