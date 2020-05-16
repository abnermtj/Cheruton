
extends Node2D

var PIECE = preload("res://Player/ActualPlayer/Hook/danglingChain2_unit.tscn")
var fixed_end_pos # these two provided by owner
var start_positn
var chain_count = 10

var chain_vector

onready var setup_done= false

func setup_chain():
	var parent = $owner.get_node("tip")
	for i in range (chain_count):
		parent = addPiece(parent)
	setup_done = true

func addPiece(parent):
	var joint = parent.get_node("CollisionShape2D/PinJoint2D")
	var piece= PIECE.instance()
	joint.add_child(piece)
	joint.node_a = parent.get_path()
	joint.node_b = piece.get_path()
	return piece

func _physics_process( delta ):
	if owner.hooked and not setup_done:
		call_deferred("setup_chain")

#removed all loops
func remove_links():
	for n in get_children():
		remove_child(n)
		n.queue_free()


