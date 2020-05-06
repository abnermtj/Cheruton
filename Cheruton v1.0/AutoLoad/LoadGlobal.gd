extends Node

const SETTINGS = "res://Display/Settings/Settings.tscn"
const PAUSE = "res://Display/Pause/Pause.tscn"
var old_nodepath
var set_pause

func _ready():
	var root = get_tree().get_root()
	DataResource.current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# Store the location of the old scene to be loaded later for settings
	if(path == SETTINGS):
		var check = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
		if(check.filename == PAUSE):
			set_pause = true

		old_nodepath = DataResource.current_scene.filename

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	DataResource.current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	DataResource.current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(DataResource.current_scene)
	if(path == old_nodepath && set_pause == true):
		KeyPress.escape_key()
		set_pause = false



