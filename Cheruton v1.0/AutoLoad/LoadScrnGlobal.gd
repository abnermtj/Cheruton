extends Control


var loader
var wait_frames
var time_max = 100 # msec

var progbar
onready var load_scrn = preload("res://Display/LoadScrn/LoadScrn.tscn")

func _ready():
	var root = get_tree().get_root()
	DataResource.current_scene = root.get_child(root.get_child_count() -1)

func goto_scene(path): # game requests to switch to this scene
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
		return
	set_process(true)

	DataResource.current_scene.queue_free() # get rid of the old scene
	DataResource.current_scene = load_scrn.instance()
	add_child(DataResource.current_scene)
	progbar = DataResource.current_scene.get_node("ColorRect/CenterContainer/VBoxContainer/LoadProg")

	wait_frames = 1

func _process(_time):
	if loader == null:
		# no need to process anymore
		set_process(false)
		return

	if wait_frames > 0: # wait for frames to let the "loading" animation show up
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max: # use "time_max" to control how much time we block this thread

		# poll your loader
		var err = loader.poll()

		if err == ERR_FILE_EOF: # load finished
			progbar.value = 100
			var resource = loader.get_resource()
			loader = null
			DataResource.current_scene.queue_free()
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else: # error during loading
			loader = null
			break

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count() * 100
	progbar.value = progress

func set_new_scene(scene_resource):
	DataResource.current_scene = scene_resource.instance()
	get_node("/root").add_child(DataResource.current_scene)
