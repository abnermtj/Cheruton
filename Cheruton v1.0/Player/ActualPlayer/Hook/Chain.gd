extends Node2D

const SPEED = 50	# The speed with which the chain moves

onready var links = $links		# caching
onready var danglinglinks = $danglinglinks

var direction := Vector2(0,0)	# The direction in which the chain was shot
var tip := Vector2(0,0)			# stores global position not local of the tip(local changes with player movement)

var chain_in_air
var hooked
var dangling_chain
var end_loop # This is the loop player hangs from, not a vector!
signal dangling_setup_done

func shoot(dir: Vector2) -> void:
	links.visible = true
	danglinglinks.visible = false

	direction = dir # assume normalized
	chain_in_air = true
	tip = self.global_position

func release() -> void:
	chain_in_air = false
	hooked = false
	danglinglinks.setup_done = false
	danglinglinks.remove_links()

func _physics_process(_delta: float) -> void:
	self.visible = chain_in_air or hooked
	if not self.visible:
		return
	if not hooked: # move an draw until collision
		var tip_loc = to_local(tip)

		links.rotation = self.position.angle_to_point(tip_loc) - deg2rad(90)
		$tip.rotation = links.rotation

		links.position = tip_loc 	# link moved to attach to the tip
		links.region_rect.size.y = tip_loc.length()		# This extends the link's repeated texture

		# this is meant to save the global position in between the delta between two physics frames in which play could move and thus affect global position of tip which is its grandhcild
		$tip.global_position = tip
		if chain_in_air:
			if $tip.move_and_collide(direction * SPEED):
				hooked = true
				chain_in_air = false
				danglinglinks.start_position = to_global(Vector2())
				danglinglinks.fixed_end_pos = tip
		tip = $tip.global_position	# set `tip` as starting position for next frame

	else : # hooked, swinging state
		links.visible = false
		danglinglinks.visible = true

func _on_danglinglinks_setup_done_chain():
	emit_signal("dangling_setup_done")
