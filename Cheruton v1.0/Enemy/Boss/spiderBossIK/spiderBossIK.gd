extends KinematicBody2D

const LEG_MOVE_COOLDOWN = .4

# Leg references
onready var a_legs = $ALegs.get_children()
onready var b_legs = $BLegs.get_children()
onready var legs = a_legs + b_legs
onready var front_left_leg = b_legs[0]
onready var front_right_leg = a_legs[0]

# Sprites
onready var head_sprite = $head
onready var feelers_sprite = $head/feelers
onready var mid_body_sprite = $midBody
onready var butt_sprite = $butt
var desired_head_pos : Vector2
var desired_feeler_pos : Vector2
var desired_mid_body_pos : Vector2
var desired_butt_pos : Vector2

# Raycasts/collisions
onready var ground_check = $groundCheck
onready var next_pos_col_check = $nextPosColCheck
onready var body_collision = $bodyCollision
onready var small_body_collision = $smallBodyCollision
onready var smaller_body_collision = $smallerBodyCollision
onready var jump_hurt_box_col_shape = $jumpHurtBox/CollisionShape2D

# General
onready var default_sprite_pos = []
var player

var velocity = Vector2()
var leg_move_timer
var cur_state
var player_found = true
var flip_legs = false
var player_in_small_look_area = false
var norm_ray_cast_enable = true
var floor_ray_cast_enable = true
var diag_ray_cast_enable = true

# INITILIALIZING
func _ready():
	for leg in legs:
		init_leg(leg)
	default_sprite_pos = [head_sprite.position, feelers_sprite.position, mid_body_sprite.position, butt_sprite.position]
	desired_head_pos = default_sprite_pos[0]
	desired_feeler_pos = default_sprite_pos[1]
	desired_mid_body_pos = default_sprite_pos[2]
	desired_butt_pos = default_sprite_pos[3]

	set_body_collision(0)

	$smallPlayerLookArea.connect("body_entered", self, "on_player_entered_small_area")
	$smallPlayerLookArea.connect("body_exited", self, "on_player_exited_small_area")

	add_to_group("needs_player_ref", true)

func init_leg(leg):
	leg.force_raycast_update()
	var col_point = leg.get_collision_point()
	if col_point: leg.step(col_point)

# UNIVERSAL MOVE FUNCTION
func move():
	velocity = move_and_slide(velocity, Vector2.UP, false, 16) # don't snap it makes it bugs when moving away from snapped position

# moves the parts of the body according to the velocity
func move_body_sprites():
	desired_head_pos = default_sprite_pos[0] + (velocity * 0.03).clamped(100)
	desired_feeler_pos = default_sprite_pos[1] + (velocity * 0.01).clamped(0)
	desired_mid_body_pos = default_sprite_pos[2] + velocity.clamped(0)
	desired_butt_pos = default_sprite_pos[3] - (velocity * 0.032).clamped(48)

func _process(delta):
	head_sprite.position = lerp (head_sprite.position, desired_head_pos, delta)
	feelers_sprite.position = lerp (feelers_sprite.position, desired_feeler_pos, delta)
	mid_body_sprite.position = lerp (mid_body_sprite.position, desired_mid_body_pos, delta)
	butt_sprite.position = lerp (butt_sprite.position, desired_butt_pos, delta)

# AREAS
func on_player_entered_small_area(body):
	player_in_small_look_area = true
func on_player_exited_small_area(body):
	player_in_small_look_area = false

# GENERAL HELPERS
func _on_states_state_changed(states_stack):
	cur_state = states_stack[0]
func set_body_collision(val):
	call_deferred("_set_body_collision", val)
func _set_body_collision(val):
	smaller_body_collision.disabled = true
	small_body_collision.disabled = true
	body_collision.disabled = true
	match val:
		0:
			body_collision.disabled = false
		1:
			smaller_body_collision.disabled = false
		2:
			small_body_collision.disabled = false

# returns true if moving A legs, B is moving B legs
func check_most_displaced_leg(leg, desired_flip, cur_max):
	leg.set_offset(velocity)

	var dist = leg.get_dist_from_desired()
	if dist and dist  > cur_max:
		cur_max = dist
		flip_legs = desired_flip
	return cur_max
