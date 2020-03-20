# Godot Notes
## SETTINGS
It is also possible to add custom configuration options and read. 
them in at run-time using the ProjectSettings singleton SETTINGS. 
NEXT TIME. Singleton are classes only instanced once. 

## SCENES
Main scence can be defined in project settings
Packed Scenes and have a .tscn filename extension.

Script instancing:
```sh
        var scene = load("res://myscene.tscn") # Will load when the script is instanced dynamic.
OR      var scene = preload("res://myscene.tscn") # Will load when parsing/reading the script.

        // Above loads scene into a resource PackedScene (as something with the same name),
        // ThatPackedScene.instance() must be called to create actual Node
        var node = scene.instance();  // "scene" is the same as above, instance() returns
                                      // a tree of nodes itself
        add_child(node); // add_child is a method from this node itself
```
Remember to execute all steps above. after loading, we don't have 
to load a gain for another instance, we only load once for as     
many instances as we want                                         

Declaring scripts as a class:
```sh
# Declare the class name here
class_name ScriptName, "res://path/to/optional/icon.svg"
```
Now ScriptName is a valid node. now it can be instanced with 
ScriptName.new() elsewhere


## PHYSICS
Right click physics material to make a node unique

## TROUBLESHOOTING
TO FIX UNCENTERED GAME SCREEN ON START: editor setting  >run > rect top left

## NODES
_ready() vs _init() . Ready is only called when all the child
nodes and itself are loaded into the scene, NOTE that all childs
need to be loaded first. init is like a constructor

Node._process(delta) vs Node._physics_process(delta), _process is called
every frame while _physics is called every physics FPS(in
settings), things which need to be calculated before physics algos
run need to be _physics_process as delta in _process is unstable
as it depends on user hardware. They extend the actual _process
and _physics_process process in the class Node

str(var) to convert a var to string if it stored as an int

NEW Node: .new() creates a new node, you need to code it to be the child as well
```sh
    s = Sprite.new() # Create a new sprite!
    add_child(s) # Add it as a child of this node.
```

Delete Node: .free() to immediately delete node and all its children.
.queue_free() to safetly free so that we do not delete mid function call

## GROUPS
func _ready():
```sh
        add_to_group("string_identifier") 
```
Groups are useful to give a common signal to all things in the
group eg.
```sh
        get_tree().call_group("enemies", "player_was_discovered")
```
SceneTree is a class managing hieracy of nodes in a scene as well as
scene themselves. So we get_tree() to get a reference to SceneTree 
where we call the call_group function. It is has even more useful
methods, switching scenes quit and pausing the game!

## NOTIFICATIONS - Good to know
```sh
        func _notification(what):  // literally "what""
```
Called when object received notification.

REFERENCE NODE BY NAME
get_node(path) works by searching immediate children
so to find a child of a child you have to :
get_node("Label/Button")  // reference by name, NOT TYPE


## SIGNALS
Signal format: _on_[EmitterNode]_[signal_name]
Very low level, it is easier to use provided virtual functions below.
OVERRIDABLE FUNCTIONS
Virtual functions (expect to be redefined in children)

```sh
                func _enter_tree():
            # When the node enters the Scene Tree, it becomes active
            # and  this function is called. Children nodes have not entered
            # the active scene yet. In general, it's better to use _ready()
            # for most cases.
            pass

        func _ready(): //NOTIFICATION_READY
            # This function is called after _enter_tree, but it ensures
            # that all children nodes have also entered the Scene Tree,
            # and became active.
            pass

        func _exit_tree():
            # When the node exits the Scene Tree, this function is called.
            # Children nodes have all exited the Scene Tree at this point
            # and all became inactive.
            pass

        func _process(delta): //NOTIFICATION_PROCESS
            # This function is called every frame.
            pass

        func _physics_process(delta):
            # This is called every physics frame.
            pass
```

