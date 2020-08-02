extends KinematicBody2D
class_name Enemy

onready var damage_val = preload("res://Enemy/DamageVal/DamageVal.tscn")
onready var hit_effect = preload("res://Effects/MobHit/HitFx.tscn")

onready var animation_player = $AnimationPlayer
onready var animation_player_fx = $AnimationPlayerFx
onready var health_bar = $HealthBar
onready var states = $states

# set by level
var level
var player

var velocity = Vector2()
var health = 15.0 setget set_health

func _ready():
	add_to_group("needs_level_ref", true)
	add_to_group("needs_player_ref", true)

func display_damage(damage_value):
	var damage_text = damage_val.instance()
	damage_text.amount = damage_value
	add_child(damage_text)

# HELPER FUNCTIONS
func set_health(val):
	health = val
	health_bar.animate_healthbar(val)
	if health <= 0.1:
		change_state("dead")

# Animation
func play_anim(string):
	animation_player.clear_queue()
	animation_player.play(string)
	animation_player.advance(0) # play immediately instead of deferred

func queue_anim(string):
	animation_player.queue(string)
func play_anim_fx(string):
	animation_player_fx.play(string)
func queue_anim_fx(string):
	animation_player_fx.queue(string)

# CAMERA
func shake_camera(dur, freq, amp, dir):
	level.shake_camera(dur, freq, amp, dir)

func change_state(state_name : String):
	states._change_state(state_name)
