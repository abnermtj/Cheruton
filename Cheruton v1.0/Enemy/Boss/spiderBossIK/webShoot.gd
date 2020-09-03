extends baseState

enum stages{ANTICIPATION = 0, SHOOT = 1, RECOVER = 2}

onready var projectile = preload("res://Enemy/Boss/spiderBossIK/acidProjectile/acidProjectile.tscn")

var stage_switch_timer : float
var stage : int
var timers_dict = {"ANTICIPATION" : .66, "SHOOT" : .5}
var player_dir : int
var shoot_dir : Vector2
var projectile_shot : bool
var desired_pos : Vector2
var goal_pos_retract : Vector2
var goal_pos_shoot : Vector2

var retract_vec = Vector2(-150,100)
var shoot_vec = Vector2(200,0)

func enter():
	player_dir = sign(owner.player.global_position.x - owner.global_position.x)
	if not player_dir: player_dir = 1


	goal_pos_retract = owner.global_position + Vector2(retract_vec.x * player_dir, retract_vec.y)
	projectile_shot = false

	stage_switch_timer = timers_dict["ANTICIPATION"]
	stage = stages.ANTICIPATION

func update(delta):
	shoot_vec = Vector2(200,0)
	stage_switch_timer -= delta
	match stage:
		stages.ANTICIPATION:
			if stage_switch_timer < 0:
				stage = stages.SHOOT
				stage_switch_timer = timers_dict.SHOOT
				goal_pos_shoot = (owner.player.global_position - owner.global_position + Vector2(0, -450)).normalized() * 200 + owner.global_position

			desired_pos = lerp(owner.global_position, goal_pos_retract, delta * 10)
			owner.velocity = (goal_pos_retract - owner.global_position) * 2

			owner.move()
			owner.move_body_sprites()

		stages.SHOOT:
			if stage_switch_timer < 0:
				stage = stages.RECOVER

			if not projectile_shot and stage_switch_timer/timers_dict["SHOOT"] < 0.2: # the number here represents the percentage left in the movent
				projectile_shot = true

				var proj = projectile.instance()
				owner.level.add_child(proj)

				proj.global_position = owner.global_position
				proj.z_index = owner.player.z_index - 1
				proj.start_shoot( proj.global_position, owner.player.global_position, 24)

			desired_pos = lerp (owner.global_position, goal_pos_shoot, delta)
			owner.velocity = (goal_pos_shoot - owner.global_position) * 3

			owner.move()
			owner.move_body_sprites()

		stages.RECOVER:
			emit_signal("changeState", "run")
func update_idle(delta):
	pass

func exit():
	pass
