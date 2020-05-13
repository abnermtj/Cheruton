extends Node2D

onready var links = $links		# caching
var direction := Vector2(0,0)	# The direction in which the chain was shot
var tip := Vector2(0,0)			# stores global position not local of the tip(local changes with player movement)

const SPEED = 50	# The speed with which the chain moves

var chain_in_air = false
var hooked = false

func shoot(dir: Vector2) -> void:
	direction = dir # assume normalized
	chain_in_air = true
	tip = self.global_position

func release() -> void:
	chain_in_air = false	# Not chain_in_air anymore
	hooked = false	# Not attached anymore

func _process(_delta: float) -> void:
	self.visible = chain_in_air or hooked
	if not self.visible:
		return
	var tip_loc = to_local(tip) # Conversion from global

	links.rotation = self.position.angle_to_point(tip_loc) - deg2rad(90)
	$tip.rotation = links.rotation

	links.position = tip_loc 	# The links are moved to start at the tip top of the link is at the tip so they translate the same amount
	links.region_rect.size.y = tip_loc.length()		# This extends links repeated texture

func _physics_process(_delta: float) -> void:
	$tip.global_position = tip	# comment thing and see what happens # update from prev frame# The player might have moved and thus updated the position of the tip -> reset it
	if chain_in_air:
		if $tip.move_and_collide(direction * SPEED):
			hooked = true
			chain_in_air = false
	tip = $tip.global_position	# set `tip` as starting position for next frame
