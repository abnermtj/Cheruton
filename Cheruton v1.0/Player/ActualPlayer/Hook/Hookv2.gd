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

#removed all loops
func remove_links():
	for n in get_children():
		remove_child(n)
		n.queue_free()

