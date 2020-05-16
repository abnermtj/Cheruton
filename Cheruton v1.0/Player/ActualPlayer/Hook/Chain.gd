extends Node2D

const SPEED_TIP = 50

var direction := Vector2(0,0)	# The direction in which the chain was shot
var tip := Vector2(0,0)			# stores global position not local of the tip(local changes with player movement)

var chain_in_air
var hooked

signal hooked(tip_pos)

# com - command, 0 -start hook, 1 -release
func _on_player_hook_command(com, dir, player_pos):
	print ("here")
	if com == 0:
		direction = dir.normalized() # incase forgot to
		chain_in_air = true
		$tip.global_position = player_pos
	else:
		chain_in_air = false
		hooked = false

func _physics_process(_delta: float) -> void:
	self.visible = chain_in_air or hooked
	if not self.visible:
		return

	if chain_in_air:
		if $tip.move_and_collide(direction * SPEED_TIP): #COLLISION
			hooked = true
			chain_in_air = false
			emit_signal("hooked", $tip.global_position)
	DataResource.dict_player.tip_pos = $tip.global_position
