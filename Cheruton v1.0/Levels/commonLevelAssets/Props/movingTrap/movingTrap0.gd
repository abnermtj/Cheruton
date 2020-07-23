extends Node2D

const iDLE_DURATION = 1.0

export var cicular_path = true
export var move_to = Vector2() # center of circle if circular path_true
export var radius = 100.0
export var speed = 30.0

var goal_pos = Vector2()
var switch = false
var duration

onready var trap = $hitArea
onready var tween = $Tween

func _ready():
	duration = move_to.length() / speed
	_on_Tween_tween_completed(null, null)

func _physics_process(delta):
	if not cicular_path:
		trap.position = trap.position.linear_interpolate(goal_pos, 0.06) # This ease in
	else:
		rotate (deg2rad(speed)*.1)

func _on_Tween_tween_completed(object, key):
	if not cicular_path:
		if switch: tween.interpolate_property(self, "goal_pos", move_to, Vector2(), duration,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, iDLE_DURATION) # waits till previous one is done
		else: tween.interpolate_property(self, "goal_pos", Vector2(), move_to, duration,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, iDLE_DURATION)
		tween.start()
		switch = not switch
	else:
		trap.position = Vector2(0, -radius) # starts pointing up

