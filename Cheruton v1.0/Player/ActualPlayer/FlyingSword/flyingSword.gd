extends KinematicBody2D

const SPEED_THROW_START = 3000
const SPEED_RETURN = 2700
const MAX_AIR_TIME = .6
const SPIN_SPEED = 2 # spins /s
const Y_LEVEL_FACTOR = 1 # swords tends to the player.pos.y during return
const PICK_UP_TIME = .15 # player can't immediately grab after throwing
const WEAPON_RETURN_DELAY = .1
enum sword_states { SHOOT = 0, HIT = 1, RETURN = 2, HIDDEN = 3}

onready var sword_state = sword_states.HIDDEN
onready var animation_player = $AnimationPlayer
onready var bodyRotation = $bodyRotation
onready var sprite = $bodyRotation/Sprite
onready var hurt_box_col = $hurtBox/CollisionShape2D
onready var hit_particles = preload("res://Player/ActualPlayer/FlyingSword/HitParticles.tscn")

var player : Node
var level : Node

var velocity : Vector2
var desired_velocity = Vector2()
var angular_velocity : float
var cur_player_pos : Vector2
var state
var active : bool
var air_timer : float
var pick_up_timer : float
var return_timer : float
var return_dust_emitted : bool = false

var col_pos : Vector2
var col_normal : Vector2

signal sword_result

func _ready():
	bodyRotation.hide()
	state = sword_states.HIDDEN
	angular_velocity = SPIN_SPEED

	$hurtBox.obj = self
	add_to_group("needs_player_ref")
	add_to_group("needs_level_ref")

func _on_flyingSword_command(command, arg):
	bodyRotation.show()

	if command == 0:
		animation_player.play("air")
		set_collision_mask_bit(0,1)


		global_position = player.global_position + 24 * player.look_direction
		active = true
		air_timer = MAX_AIR_TIME

		var dir = arg.normalized()
		velocity = dir * SPEED_THROW_START # arg is direction
		level.shake_camera(.1, 13.2, 8, dir)
		state = sword_states.SHOOT
	elif command == 1: # player orders return
		state = sword_states.RETURN
	elif command == 2: # cut scene special return to hand
		animation_player.play("air")
		state = sword_states.RETURN
		bodyRotation.position += Vector2(-40, -80) # hand of player

func _physics_process(delta):
	if not active: return

	cur_player_pos = player.global_position
	var bodies_in_collection_area = $collectionArea.get_overlapping_bodies()
	var bodies_in_limit_area = $limitArea.get_overlapping_bodies()

	if state == sword_states.HIT:
		pick_up_timer -= delta
		if bodies_in_collection_area and pick_up_timer < 0: # playertouches sword
			state = sword_states.RETURN
			animation_player.play("air")
		if not bodies_in_limit_area:
			state = sword_states.RETURN
			animation_player.play("air")

	match state:
		sword_states.SHOOT:
			hurt_box_col.disabled = false
			bodyRotation.rotate(angular_velocity)

			air_timer -= delta
			if air_timer < 0 :
				state = sword_states.RETURN
				return

			velocity = lerp(velocity, Vector2(), delta * 2.21)

			var col = move_and_collide(velocity*delta)

			if col:
				if not col.collider.is_in_group("flyingPoleColliders"):
					state = sword_states.RETURN
					return
				col_pos = col.position
				col_normal = col.normal

				pick_up_timer = PICK_UP_TIME
				velocity = Vector2()
				bodyRotation.rotation = Vector2.UP.angle_to(col_normal)

				animation_player.play("stuck")
				emit_dust("hit")
				level.shake_camera(.1, 13.2, 16, -col_normal)

				state = sword_states.HIT
				emit_signal("sword_result", 0, global_position, col_normal)

		sword_states.HIT:
			hurt_box_col.disabled = true
			return_dust_emitted = false

		sword_states.RETURN:
			if not return_dust_emitted:
				return_dust_emitted = true
				level.shake_camera(.1, 13.2, 20, col_normal)
				return_timer = WEAPON_RETURN_DELAY
				global_position += col_normal * 8
				emit_dust("return")

			return_timer -= delta
			if return_timer > 0:
				return
			animation_player.play("air")

			hurt_box_col.disabled = false
			set_collision_mask_bit(0,0)
			bodyRotation.rotate(angular_velocity)

			var direction = cur_player_pos - global_position # go towards player
			desired_velocity = direction.normalized() * SPEED_RETURN + Vector2(0,Y_LEVEL_FACTOR * (cur_player_pos.y-global_position.y)) # curves the return
			desired_velocity = desired_velocity.normalized() * SPEED_RETURN


			var vel_lerp_factor = 1.8 + min(abs(return_timer),1.3)
			velocity = lerp(velocity, desired_velocity, delta* vel_lerp_factor) # 2 is slow
			move_and_collide(velocity * delta)

			if (global_position - cur_player_pos).length() < 70:
				state = sword_states.HIDDEN
			emit_signal("sword_result", 1, Vector2(), Vector2())

		sword_states.HIDDEN:
			bodyRotation.position = Vector2(0, 0) # this is specifically for the cutscene
			bodyRotation.hide()
			active = false

			hurt_box_col.disabled = true
			emit_signal("sword_result", 2, Vector2(), Vector2())

func emit_dust(type : String):
	var hit_particles_instance = hit_particles.instance()
	hit_particles_instance.process_material.direction = Vector3(col_normal.x, col_normal.y, 0.0)
	hit_particles_instance.global_position = col_pos - level.global_position

	match type:
		"hit":
			hit_particles_instance.process_material.initial_velocity = 400.0
		"return":
			hit_particles_instance.process_material.initial_velocity = 200.0

	level.add_child(hit_particles_instance)
	hit_particles_instance.emitting = true

