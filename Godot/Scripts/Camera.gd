extends Camera2D

export (OpenSimplexNoise) var noise

onready var _player = get_owner().find_node("Player")
onready var _player_physical = get_owner().find_node("PlayerPhysical")

var shake_on = false
var shake_x = 0
var shake_y = 0

var time = 0
const MAX_SHAKE_DISTANCE = 5
const MAX_ROTATE_DISTANCE = 3
var trauma = 0
var time_scale = 100 # the bigger, the faster it shakes
var shake_entropy = 1.0 # for decaying or accelerating shake

var camera_to_player = true
var zoom_scale = ConstsEnums.ZOOM_DEFAULT_SCALE
var distance = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = _player.position

func _process(delta):
	if shake_on:
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
	if camera_to_player:
		#self.position = _player.position
		var temp_pos = _player_physical.global_position
		
		# shift camera in the direction of rotation degree of player to see less ground
		var deg_rad = deg2rad(_player.rotation_degrees - 90) # we substract 90 because rotation_degree starts at 0 while facing straight upward
		var shift_vector = Vector2(cos(deg_rad), sin(deg_rad)) # this is already normalized
		shift_vector = shift_vector * 130 # multiplication factor is how much (pixels?) to shift camera
		temp_pos.x += shift_vector.x
		temp_pos.y += shift_vector.y
		
		self.position = lerp(self.position, temp_pos, .3)
		
#		if zoom_scale == ConstsEnums.ZOOM_DEFAULT_SCALE:
#			self.position = lerp(self.position, temp_pos, .3)
#		elif zoom_scale == ConstsEnums.ZOOM_DOOR_SCALE:
#			self.position = lerp(self.position, temp_pos, .1)
		# self.position = lerp(self.position, temp_pos, .1)
		# self.position = temp_pos # camera directly follows player with no smoothness
		
		# add shake values
#		self.position.x = self.position.x + shake_x
#		self.position.y = self.position.y + shake_y
		
		self.zoom.x = lerp(self.zoom.x, zoom_scale, .03)
		self.zoom.y = lerp(self.zoom.y, zoom_scale, .03)
	pass

func zoom_door() -> void:
	zoom_scale = ConstsEnums.ZOOM_DOOR_SCALE

func zoom_default() -> void:
	zoom_scale = ConstsEnums.ZOOM_DEFAULT_SCALE

#func zoom_train() -> void:
#	zoom_scale = ConstsEnums.ZOOM_TRAIN_SCALE
#
#func zoom_platform() -> void:
#	zoom_scale = ConstsEnums.ZOOM_PLATFORM_SCALE
#	#zoom_scale = 2
