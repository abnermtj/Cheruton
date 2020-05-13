extends Node2D

# This is a variable length chain, based on the fix length ones found online
# one end would be fixed
export (float) var GRAVITY := 100.0
export (float) var RESISTANCE := 0.70
export (float) var CHAIN_LINK_LENGTH := 20.0


var fixed_end_pos = Vector2(500,500) # these two provided by the parent of the scene that inherits this
var start_position = Vector2(300,500)
onready var chain_count = 0
onready var chain_vector = fixed_end_pos - start_position# from start to end
var loops = []
var links = []

var unit = load("res://Player/ActualPlayer/Hook/Dangling_chain_unit.tscn")
var pivot #the fixed point in thechain

func _ready():
	set_physics_process(false) # wait for th setup to finish first
	call_deferred( "setup_chain" )

# create chain from start to end
func setup_chain():
	loops = []
	links = []
	chain_count = fixed_end_pos.distance_to(start_position)/CHAIN_LINK_LENGTH
	# start form the start position and build to the end
	# the initial instance doesnt have a parent
	var prev = unit.instance()
	add_child(prev)
	var curr_loop = prev
	var curr_link
	prev.fixed = true
	pivot = prev
#	loops.append(curr_loop)
	curr_loop.pos_cur = start_position
	curr_loop.pos_prv = start_position
	if chain_count <= 1: # avoid division by 0 below
		return

	# this is basically a linked list with the ends removed for links dictionary
	for i in range(1 , chain_count): # i goes upto chaincount -1
		curr_loop = unit.instance()
		curr_link = curr_loop.find_node("link")
		add_child(curr_loop)
		# making the links
		print(prev, curr_loop)
		curr_link.parent = prev
		curr_link.child = curr_loop
		# adding to the list
		loops.append(curr_loop)
		links.append(curr_link)
#		if i == 1:
#			curr_loop.fixed = true
		curr_loop.pos_cur = start_position + i * chain_vector/ (chain_count-1)
		curr_loop.pos_prv = curr_loop.pos_cur # so moves normally once set

		prev = curr_loop
	links[-1].child = curr_loop


	for loop in loops:
		loop.global_position = loop.pos_cur
#		print ("curr", loop, "chi ", loop.get_node("link").child , " parr ",loop.get_node("link").parent , "fix is ", loop.fixed)#, " pos at ", loop.global_position)

	for link in links:
#		print("current link parent is ", link.parent, "child is ", link.child)
		link.global_position = ( link.parent.global_position + link.child.global_position ) * 0.5 # middle between parent and child
		link.global_rotation = link.parent.pos_cur.angle_to_point( link.child.pos_cur ) + PI / 2
	set_physics_process(true)
# EXPLANATION OF BELOW IN verlet_chain.gd
func _physics_process( delta ):
#	if loops.size()>0:
#		print (loops[-1].global_position)
	_update_loops( delta )
	for i in range(0,50):
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
		if distance < 0.01: distance = 0.01 # since distance cannot equal to 0, we dividing below
		var difference = CHAIN_LINK_LENGTH - distance # if distane is too large > chain link length
		var percentage = difference / distance
		vector *= percentage / 2 # devide to minus from both sides
		link.parent.pos_cur -= vector
		link.child.pos_cur += vector

func _render_frame():
	for loop in loops:
		loop.global_position = loop.pos_cur
	links[0].parent.pos_cur = get_viewport().get_mouse_position()
	links[0].parent.global_position = get_viewport().get_mouse_position()
	links[3].child.pos_cur = Vector2(400,500) # debugging
#	print(links[0].parent)
	for link in links:
		link.global_position = ( ( link.parent.global_position + link.child.global_position ) * 0.5 )#.round()
		link.global_rotation = link.parent.pos_cur.angle_to_point( link.child.pos_cur ) + PI / 2




