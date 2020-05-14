extends Node2D
class_name VerletChain
# THIS CLASS IS THE TOP OF THE CHAIN
# export is good so each node that extends from this has independant graity resistance..
export (float) var GRAVITY := 100.0
export (float) var RESISTANCE := 0.70
export (float) var CHAIN_LINK_LENGTH := 10.0

var loops = []
var links = []

func _ready():
	call_deferred( "setup_chain" )  # call it when apt

func setup_chain():
	# find anchor
	loops = []
	links = []
	var children = get_children()
	for c in children:
		if c is VerletLoop:
			# only one direct cchild
			loops.append( c )
			break

	# recursively create chain, loops array will have reference to all loops inclusding grand children..
	create_chain( loops[0] )  # also fills links

	# set initial positions
	for loop in loops:
#		print ("curr", loop, "chi ", loop.get_node("link").child , " parr ",loop.get_node("link").parent , "fix is ", loop.anchor)
		loop.pos_cur = loop.global_position
		loop.pos_prv = loop.global_position
	for link in links:
		# note link position automatically set
#		print("current link parent is ", link.parent, "child is ", link.child)
		link.global_position = ( link.parent.global_position + link.child.global_position ) * 0.5 # middle between parent and child
		link.global_rotation = link.parent.pos_cur.angle_to_point( link.child.pos_cur ) + PI / 2 # straight above means  angle to point is 0
# we add PI/2 or 90 degrees because for global rotation 0 degrees is a vector pointing to the right. so to convert straight up being 0degrees to right
# we have add 90 degrees to whatever value from angle to point

func create_chain( parent ):
	var found_loop = false
	var children = parent.get_children()
	for c in children:
		if c is VerletLoop:
			loops.append( c )
			found_loop = true
			break
	for c in children:
		if c is VerletLink:
			links.append( c )
			c.parent = parent
			c.child = loops[-1] #-1 is the last element
			break
	if found_loop:
		create_chain( loops[-1] ) # keeps recursively chaining  latest loop till no loops


func _physics_process( delta ):
	_update_loops( delta )
	for i in range(0,2):
		_constrain_links( delta )
	_render_frame()

#move loop in direction of loop above it
func _update_loops( delta ):
	for loop in loops:
		if loop.anchor:
			loop.pos_prv = loop.pos_cur
			loop.pos_cur = loop.global_position
#			loop.pos_cur =  get_viewport().get_mouse_position()
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
#
#		if percentage > 1: percentage = 1   # move towards it 1 means to close gap completely child will be at parent noded
		vector *= percentage
		link.child.pos_cur += vector
	pass

func _render_frame():
	for loop in loops:
		loop.global_position = loop.pos_cur#.round()
	for link in links:
		link.global_position = ( ( link.parent.global_position + link.child.global_position ) * 0.5 )#.round()
		link.global_rotation = link.parent.pos_cur.angle_to_point( link.child.pos_cur ) + PI / 2
	pass # doesnt actaully do anythings no return value, not even null, lietrally pass

