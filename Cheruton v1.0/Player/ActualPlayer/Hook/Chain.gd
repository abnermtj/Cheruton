extends Node2D

const SPEED_TIP_START = 5400
const REEL_SPEED = 4000
const MIN_TIP_SPEED = 1900

onready var chain_state = chain_states.HIDDEN
enum chain_states { SHOOT = 0, HOOKED = 1, REEL = 2, HIDDEN = 3}

var direction := Vector2(0,0) # The direction in which the chain was shot

var cur_player_pos
var speed_tip

onready var tween = $Tween
onready var link  = $link
onready var tip = $tip

signal hooked(tip_pos)
signal shake

# com - command, 0 -start hook, 1 -release
func _on_player_hook_command (com, dir, player_pos):
	if com == 0: #START
		chain_state = chain_states.SHOOT
		link.start() # link is the rope

		visible = true
		direction = dir.normalized()
		tip.global_position = player_pos # start at player
		cur_player_pos = player_pos

		tween.interpolate_property(self, "speed_tip", SPEED_TIP_START, 0, .66, Tween.TRANS_SINE,Tween.EASE_OUT)
		tween.start()

		tip.get_node("CollisionShape2D").disabled = false
	else: # END
		start_reel()

func start_reel():
	chain_state = chain_states.REEL
	link.release()
	tip.get_node("CollisionShape2D").disabled = true

func _physics_process(delta: float) -> void:
	match(chain_state):
		chain_states.SHOOT:
			if speed_tip < MIN_TIP_SPEED:
				start_reel()
				return

			var col = tip.move_and_collide(direction * speed_tip * delta) # in initial direction of player input
			if col :
				chain_state = chain_states.HOOKED
				emit_signal("hooked",0, tip.global_position)
				emit_signal("shake", .105, 7, 3, -(tip.global_position - cur_player_pos).normalized()+ Vector2(.1,.1))
		chain_states.HOOKED:
			pass
		chain_states.REEL:
			direction = cur_player_pos - tip.global_position # tip to player
			tip.move_and_collide(direction.normalized() * REEL_SPEED * delta)
			if (link.global_position - cur_player_pos).length() < 100:
				chain_state = chain_states.HIDDEN
				visible = false
		chain_states.HIDDEN:
			pass

func _ready():
	visible = false

func _process(delta):
	if visible:
		cur_player_pos = DataResource.dict_player.player_pos

		link.c = max((cur_player_pos - tip.global_position).length(),1)
		link.rotation = cur_player_pos.angle_to_point(tip.global_position)
		link.global_position = tip.global_position

		tip.rotation = cur_player_pos.angle_to_point(tip.global_position)


