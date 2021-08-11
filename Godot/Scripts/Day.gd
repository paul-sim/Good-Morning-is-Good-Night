extends Node2D

export(ConstsEnums.DAY) var _day = ConstsEnums.DAY.ZERO
#onready var _save_manager = get_owner().find_node("SaveManager", true, false)
#
## Called when the node enters the scene tree for the first time.
func _ready():
#	if _day == ConstsEnums.DAY.ONE || _day == ConstsEnums.DAY.THREE:
#		$Wall/Fence.position = ConstsEnums.HIDE_VECTOR
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _exit_tree():
	self.queue_free()

func get_day():
	return _day


# function name is confusing. it only makes sense for day3. it's the opposite for day1
func _on_FenceErect_Area2D_area_entered(area):
	if area.get_parent().get_parent().name == "Player":
		if _day == ConstsEnums.DAY.THREE:
			get_owner().find_node("Door").position = ConstsEnums.HIDE_VECTOR
			$Wall/Fence.position = Vector2.ZERO
			$Wall/Fence/Sprite/StopRight_Area2D.position = Vector2.ZERO
		elif _day == ConstsEnums.DAY.ONE:
			get_owner().find_node("Door").position = Vector2.ZERO
			$Wall/Fence.position = ConstsEnums.HIDE_VECTOR
			$Wall/Fence/Sprite/StopRight_Area2D.position = ConstsEnums.HIDE_VECTOR

# function name is confusing. it only makes sense for day3. it's the opposite for day1
func _on_DoorErect_Area2D_area_entered(area):
	if area.get_parent().get_parent().name == "Player":
		if _day == ConstsEnums.DAY.THREE:
			get_owner().find_node("Door").position = Vector2.ZERO
			$Wall/Fence.position = ConstsEnums.HIDE_VECTOR
			$Wall/Fence/Sprite/StopRight_Area2D.position = ConstsEnums.HIDE_VECTOR
			# print("after = " + str($Wall/Fence/Sprite/StopRight_Area2D/CollisionShape2D.get_global_position().y))
		elif _day == ConstsEnums.DAY.ONE:
			get_owner().find_node("Door").position = ConstsEnums.HIDE_VECTOR
			$Wall/Fence.position = Vector2.ZERO
			$Wall/Fence/Sprite/StopRight_Area2D.position = Vector2.ZERO

func _on_StopRight_Area2D_area_entered(area):
	if area.get_parent().get_parent().name == "Player":
		if _day == ConstsEnums.DAY.THREE:
			get_owner().find_node("Player").set_stop_right_direction(true)
		elif _day == ConstsEnums.DAY.ONE:
			get_owner().find_node("Player").set_stop_left_direction(true)

func _on_StopRight_Area2D_area_exited(area):
	if area.get_parent().get_parent().name == "Player":
		if _day == ConstsEnums.DAY.THREE:
			get_owner().find_node("Player").set_stop_right_direction(false)
		elif _day == ConstsEnums.DAY.ONE:
			get_owner().find_node("Player").set_stop_left_direction(false)
		
		
