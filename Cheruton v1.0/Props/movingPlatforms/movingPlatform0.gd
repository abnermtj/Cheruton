extends Node2D

const iDLE_DURATION = 1.0

export var move_to = Vector2()
export var speed = 3.0

var goal_pos = Vector2()
var switch = true
var duration : float

onready var platform = $platformBody
onready var tween = $Tween

func _ready():
	duration = move_to.length() / speed
	tween.interpolate_property(self, "goal_pos", Vector2(), move_to, duration,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, iDLE_DURATION)
	tween.start()

func _physics_process(delta):
	platform.position = platform.position.linear_interpolate(goal_pos, 0.06) # This ease in


func _on_Tween_tween_completed(object, key):
	if switch: tween.interpolate_property(self, "goal_pos", move_to, Vector2(), duration,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, iDLE_DURATION) # waits till previous one is done
	else: tween.interpolate_property(self, "goal_pos", Vector2(), move_to, duration,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, iDLE_DURATION)
	switch = not switch
	tween.start()
