extends Camera2D

export (OpenSimplexNoise) var noise

onready var _player = get_owner().find_node("PlayerFlatWorld")
onready var _stick_left_area2D = get_owner().find_node("StickLeft_Area2D")
onready var _stick_right_area2D = get_owner().find_node("StickRight_Area2D")

var _shake_on = false
var shake_x = 0
var shake_y = 0

var time = 0
const MAX_SHAKE_DISTANCE = 10
const MAX_ROTATE_DISTANCE = 3
var trauma = 0
var time_scale = 300 # the bigger, the faster it shakes
var shake_entropy = 1.0 # for decaying or accelerating shake

var _camera_to_player = true
var _camera_fix_on_position = false
var _camera_fix_position = Vector2.ZERO
var _camera_fixed_left = false
var _zoom_scale = ConstsEnums.ZOOM_DEFAULT_SCALE
var distance = 0
var _at_end = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if _shake_on:
		### camera shake start ###
		time += delta
		var shake = pow(trauma, 2)
		shake_x = noise.get_noise_3d(time * time_scale, 0, 0) * MAX_SHAKE_DISTANCE * shake
		shake_y = noise.get_noise_3d(0, time * time_scale, 0) * MAX_SHAKE_DISTANCE * shake
		# rotation_degrees = noise.get_noise_3d(0, time * time_scale, 0) * MAX_ROTATE_DISTANCE

		if ! _player.get_is_moving():
			if shake < 1:
				trauma = clamp (trauma + (delta * shake_entropy), 0, 1)
		else:
			if shake > 0:
				trauma = clamp (trauma - (delta * shake_entropy), 0, 1)

	### camera shake end ###

func _physics_process(delta):
	# camera stays on player
	if _camera_to_player:
		var temp_pos = _player.position
		temp_pos.y -= ConstsEnums.CAMERA_FLAT_WORLD_Y_OFFSET
		self.position = lerp(self.position, temp_pos, .1)
		
		# add shake values
		self.position.x = self.position.x + shake_x
		self.position.y = self.position.y + shake_y
		
		self.zoom.x = lerp(self.zoom.x, _zoom_scale, .1)
		self.zoom.y = lerp(self.zoom.y, _zoom_scale, .1)
	elif _camera_fix_on_position:
		var temp_pos = _camera_fix_position
		if _camera_fixed_left:
			temp_pos.y -= ConstsEnums.CAMERA_FLAT_WORLD_Y_OFFSET
		self.position = lerp(self.position, temp_pos, ConstsEnums.ZOOM_OUT_SPEED)

		self.zoom.x = lerp(self.zoom.x, _zoom_scale, ConstsEnums.ZOOM_OUT_SPEED)
		self.zoom.y = lerp(self.zoom.y, _zoom_scale, ConstsEnums.ZOOM_OUT_SPEED)
		

func zoom_door() -> void:
	_zoom_scale = ConstsEnums.ZOOM_DOOR_SCALE

func zoom_default() -> void:
	_zoom_scale = ConstsEnums.ZOOM_DEFAULT_SCALE

func zoom_left_wall(area) -> void:
	_camera_fix_position = _stick_left_area2D.get_node("FixPosition").get_global_position()
	# _zoom_scale = ConstsEnums.ZOOM_OUT_SCALE
	_camera_fixed_left = true
	_camera_to_player = false
	_camera_fix_on_position = true

func zoom_right_wall(area) -> void:
	_camera_fix_position = _stick_right_area2D.get_node("FixPosition").get_global_position()
	# _zoom_scale = ConstsEnums.ZOOM_OUT_SCALE
	_camera_to_player = false
	_camera_fix_on_position = true

func _on_StickLeft_Area2D_area_entered(area):
	if area.get_parent().name == "PlayerFlatWorld":
		zoom_left_wall(area)

func _on_StickLeft_Area2D_area_exited(area):
	_camera_fixed_left = false
	if area.get_parent().name == "PlayerFlatWorld":
		camera_to_player()
	
func camera_to_player():
	zoom_default()
	_camera_fix_on_position = false
	_camera_to_player = true

func shake():
	_shake_on = true

func _on_StickRight_Area2D_area_entered(area):
	if _at_end:
		return
	if area.get_parent().name == "PlayerFlatWorld":
		zoom_right_wall(area)

func _on_StickRight_Area2D_area_exited(area):
	if _at_end:
		return
	if area.get_parent().name == "PlayerFlatWorld":
		camera_to_player()

func camera_end_frame():
	_camera_fix_position = get_parent().get_node("camera_end_frame").position
	_at_end = true
	_camera_fix_on_position = true
