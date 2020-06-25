extends KinematicBody2D

const LEG_MOVE_COOLDOWN = .4
onready var a_legs = $ALegs.get_children()
onready var b_legs = $BLegs.get_children()
onready var legs = a_legs + b_legs
onready var head_sprite = $head
onready var feelers_sprite = $head/feelers
onready var mid_body_sprite = $midBody
onready var butt_sprite = $butt
onready var ground_check = $groundCheck
onready var next_pos_col_check = $nextPosColCheck
onready var body_collision = $bodyCollision
onready var smaller_body_collision = $smallerBodyCollision
onready var default_sprite_pos = []

onready var jump_hurt_box_col_shape = $jumpHurtBox/CollisionShape2D

var velocity = Vector2()
var leg_move_timer
var cur_state
var player_found = true
var player_in_small_look_area = false
var norm_ray_cast_enable = true
var floor_ray_cast_enable = true
var diag_ray_cast_enable = true
# INITILIALIZING
func _ready():
	for leg in legs:
		init_leg(leg)
	default_sprite_pos = [head_sprite.position, feelers_sprite.position, mid_body_sprite.position, butt_sprite.position]

	set_body_collision(0)

	$smallPlayerLookArea.connect("body_entered", self, "on_player_entered_small_area")
	$smallPlayerLookArea.connect("body_exited", self, "on_player_exited_small_area")
func init_leg(leg):
	leg.force_raycast_update()
	var col_point = leg.get_collision_point()
	if col_point: leg.step(col_point)


# UNIVERSAL MOVE FUNCTION
func move():
	return move_and_slide(velocity, Vector2.UP)
# moves the parts of the body according to the velocity
func move_body_sprites():
	head_sprite.position = default_sprite_pos[0] + (velocity * 0.03	).clamped(100)
	feelers_sprite.position = default_sprite_pos[1] + (velocity * 0.01).clamped(0)
	mid_body_sprite.position = default_sprite_pos[2] + velocity.clamped(0)
	butt_sprite.position = default_sprite_pos[3] - (velocity * 0.032).clamped(48)

# AREAS
func on_player_entered_small_area(body):
	player_in_small_look_area = true
func on_player_exited_small_area(body):
	player_in_small_look_area = false

# GEENERAL HELPERS
func _on_states_state_changed(states_stack):
	cur_state = states_stack[0]
func set_body_collision(val):
	smaller_body_collision.disabled = true
	body_collision.disabled = true

	match val:
		0:
			body_collision.disabled = false
		1:
			smaller_body_collision.disabled = false
