extends Node

func _ready():
	var root = get_tree().get_root()
	DataResource.current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	DataResource.current_scene.free()

	var scene = ResourceLoader.load(path)

	DataResource.current_scene = scene.instance()
	get_tree().get_root().add_child(DataResource.current_scene)
