extends Camera2D

export (OpenSimplexNoise) var noise

var _shake_on = false
var shake_x = 0
var shake_y = 0

var time = 0
const MAX_SHAKE_DISTANCE = 20
const MAX_ROTATE_DISTANCE = 3
var trauma = 0
var time_scale = 600 # the bigger, the faster it shakes
var shake_entropy = 0.5 # for decaying or accelerating shake

var _camera_to_player = true
var _camera_fix_on_position = false
var _camera_fix_position = Vector2.ZERO
var _camera_fixed_left = false
var _zoom_scale = ConstsEnums.ZOOM_DEFAULT_SCALE
var distance = 0
var _at_end = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if _shake_on:
		### camera shake start ###
		time += delta
		var shake = pow(trauma, 2)
		shake_x = noise.get_noise_3d(time * time_scale, 0, 0) * MAX_SHAKE_DISTANCE * shake
		shake_y = noise.get_noise_3d(0, time * time_scale, 0) * MAX_SHAKE_DISTANCE * shake
		# rotation_degrees = noise.get_noise_3d(0, time * time_scale, 0) * MAX_ROTATE_DISTANCE

		if shake < 1:
			trauma = clamp (trauma + (delta * shake_entropy), 0, 1)

	### camera shake end ###


func _physics_process(delta):
# camera stays on player
	var temp_pos = Vector2.ZERO
	self.position = lerp(self.position, temp_pos, .1)
	
	# add shake values
	self.position.x = self.position.x + shake_x
	self.position.y = self.position.y + shake_y
	
	self.zoom.x = lerp(self.zoom.x, _zoom_scale, .1)
	self.zoom.y = lerp(self.zoom.y, _zoom_scale, .1)

func shake():
	_shake_on = true
