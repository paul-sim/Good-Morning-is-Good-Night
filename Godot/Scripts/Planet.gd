extends Node2D

onready var _planet = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	pass

func draw_circle_custom(radius, maxerror = 0.25):

	if radius <= 0.0:
		return

	var maxpoints = 1024 # I think this is renderer limit

	var numpoints = ceil(PI / acos(1.0 - maxerror / radius))
	numpoints = clamp(numpoints, 3, maxpoints)

	var points = PoolVector2Array([])

	for i in numpoints:
		var phi = i * PI * 2.0 / numpoints
		var v = Vector2(sin(phi), cos(phi))
		points.push_back(v * radius)

	#draw_colored_polygon(points, Color(0, 0, 0, 1))
	draw_colored_polygon(points, Color8(188, 197, 149))


func _draw():
	draw_circle_custom(ConstsEnums.PLANET_RADIUS)
	# draw_circle_custom(1500)
	# draw_circle(Vector2(0,0), 1500, Color(188, 197, 149))
