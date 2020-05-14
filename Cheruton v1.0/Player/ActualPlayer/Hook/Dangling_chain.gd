extends Node2D

# This is a variable length chain, based on the fix length ones found online
# one end would be fixed

#need to set below as instanced scenes take these default values
export (float) var GRAVITY := 150.0
export (float) var RESISTANCE := 0.96
export (float) var CHAIN_LINK_LENGTH := 100.0


var fixed_end_pos # these two provided by owner
var start_position
var chain_count = 0

var chain_vector
var loops = []
var links = []

var setup_done = false
var unit = load("res://Player/ActualPlayer/Hook/Dangling_chain_unit.tscn")

signal setup_done_chain
# create chain from start to end
func setup_chain():
	chain_vector = fixed_end_pos - start_position

#	print("chain-----fix end----",fixed_end_pos)
#	print("chain-----startend----",start_position)
	loops = []
	links = []
	chain_count = int(fixed_end_pos.distance_to(start_position)/CHAIN_LINK_LENGTH)

	var prev = unit.instance()
	add_child(prev)
	var curr_loop = prev
	var curr_link
#	prev.fixed = true # don't need to fix
	prev.modulate = Color(0,0,0)

	curr_loop.pos_cur = start_position
	curr_loop.pos_prv = start_position
	if chain_count <= 1: # avoid division by 0 below
		return
#	print("prev " , prev)

	# make a reference to the first item which originates from the player, so we can apply physics to it
	DataResource.dict_player.hook_point = prev

	# this is basically a linked list with the ends removed for links dictionary
	for i in range(1 , chain_count): # i goes up to chaincount -1
		curr_loop = unit.instance()
		if i == 1:
			owner.end_loop = curr_loop
		curr_link = curr_loop.find_node("link")
		add_child(curr_loop)
		# making the links
		print(prev, curr_loop)
		curr_link.parent = prev
		curr_link.child = curr_loop
		# adding to the list
		loops.append(curr_loop)
		links.append(curr_link)

		curr_loop.pos_cur = start_position + i * chain_vector/ (chain_count-1)
		curr_loop.pos_prv = curr_loop.pos_cur # so moves normally once set

		prev = curr_loop
	# edge cases not covered by loop aboce
	links[-1].child = curr_loop


	for loop in loops:
		loop.global_position = loop.pos_cur
#		print ("curr", loop, "chi ", loop.get_node("link").child , " parr ",loop.get_node("link").parent , "fix is ", loop.fixed)#, " pos at ", loop.global_position)

	for link in links:
#		print("current link parent is ", link.parent, "child is ", link.child)
		link.global_position = ( link.parent.global_position + link.child.global_position ) * 0.5 # middle between parent and child
		link.global_rotation = link.parent.pos_cur.angle_to_point( link.child.pos_cur ) + PI / 2
	setup_done = true
	emit_signal("setup_done_chain")
# EXPLANATION OF BELOW IN verlet_chain.gd
func _physics_process( delta ):
	if owner.hooked and not setup_done:
		call_deferred("setup_chain")

	if setup_done:
		_update_loops( delta )
		for i in range(0,1): # imrpoves correctness each pass 40 is good
			_constrain_links( delta )
		_render_frame()

func _update_loops( delta ):
	for loop in loops:
		if loop.fixed:
			loop.pos_prv = loop.pos_cur
			loop.pos_cur = loop.global_position
		else:
			var vel = ( loop.pos_cur - loop.pos_prv ) * RESISTANCE # dist between two orgin vectors is the vector from one ppoint to other
			loop.pos_prv = loop.pos_cur
			loop.pos_cur += vel # this causes lagging behind
			loop.pos_cur.y += GRAVITY * delta


# Move links child towards the parent position if they are too far apart
func _constrain_links( delta ):
	for link in links:

		var vector = ( link.child.pos_cur - link.parent.pos_cur )# effectively speed since prev process cycle
		var distance = link.child.pos_cur.distance_to( link.parent.pos_cur )
#		print(links[0].parent)
#		if (links[0]== link):
#			print(links[0].parent,"vector is", vector, "child pos is ", link.child.global_position, "parent pos is", link.parent.global_position, distance)
		if distance < 0.01: distance = 0.01 # since distance cannot equal to 0, we dividing below
		var difference = CHAIN_LINK_LENGTH - distance # if distane is too large > chain link length
		var percentage = difference / distance
		vector *= percentage / 2 # devide to minus from both sides
		link.parent.pos_cur -= vector # vector goes from parent to child notice the signs
		link.child.pos_cur += vector

		# NEED OFFSET else x ray may
		if link.parent.pos_cur.y > link.parent.y_limit: #  beed to consider last child later on, NOT IMPLEMENTED YET NOT SURE ABOUT THIS  I THINK LAST CHILD IS FIXED>n
			link.parent.pos_cur.y = link.parent.y_limit
		if link.parent.pos_cur.x > link.parent.x_limit_right: #   NOT SURE ABOUT THIS  I THINK LAST CHILD IS FIXED>need to consider last child later on, NOT IMPLEMENTED YET
			link.parent.pos_cur.x = link.parent.x_limit_right
		if link.parent.x_limit_right != INF:
			print("here", link.parent.pos_cur.x, link.parent.x_limit_right)

#		if link.parent.has_collide == true: # the ray cast in the single unit needs to be extended greater than than the length of a chain * look ahead
#			link.parent.pos_cur.y = link.parent.y_limit





func _render_frame():
#	links[0].parent.global_position = links[0].parent.pos_cur
	for loop in loops:
		loop.global_position = loop.pos_cur
#		print(loop)
#	links[0].parent.pos_cur = DataResource.dict_player.player_pos
#	links[0].parent.global_position = DataResource.dict_player.player_pos
	links[-1].child.pos_cur = owner.tip
	links[-1].child.global_position = owner.tip
	# debugging
#	links[0].parent.pos_cur = get_viewport().get_mouse_position()
#	links[0].parent.global_position = get_viewport().get_mouse_position()
#	links[3].child.pos_cur = Vector2(400,500)
	for link in links:
		link.global_position = ( ( link.parent.global_position + link.child.global_position ) * 0.5 )#.round()
		link.global_rotation = link.parent.pos_cur.angle_to_point( link.child.pos_cur ) + PI / 2

#removed all loops
func remove_links():
	for n in get_children():
		remove_child(n)
		n.queue_free()

