extends Enemy

var velocity
var player_found = false
var start_pos
var attacking = false
var previous_anim

onready var states = $states
onready var animation_player = $AnimationPlayer
func _ready():
	start_pos = global_position
	$playerFindArea.connect("body_entered", self, "on_player_found")
	$playerFindArea.connect("body_exited", self, "on_player_exit")

func on_player_found(player_body):
	player_found = true
	attacking = true

func on_player_exit(player_body):
	player_found = false
	$aggroTimer.start(1)

func _on_aggroTimer_timeout():
	if not player_found:
		attacking = false

func play_anim(string):
	if animation_player:
		if string != "previous":
			animation_player.play(string)
			previous_anim = string
		else:
			animation_player.play(previous_anim)

func move():
	if  ["run", "slide", "idle"].has(states.current_state.name):
		move_and_slide_with_snap(velocity,Vector2.DOWN * 15, Vector2.UP)
	else:
		move_and_slide(velocity, Vector2.UP)
