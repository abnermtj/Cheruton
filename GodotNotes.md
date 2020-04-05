# Godot Notes
## SETTINGS
It is also possible to add custom configuration options and read. <br/> 
them in at run-time using the ProjectSettings singleton SETTINGS.  <br/>
NEXT TIME. Singleton are classes only instanced once. <br/>

## SCENES
Main scence can be defined in project settings Packed Scenes<br/> 
and have a .tscn filename extension.                        <br/> 

Script instancing:
```sh
        var scene = load("res://myscene.tscn") # Will load when the script is instanced dynamic.
OR      var scene = preload("res://myscene.tscn") # Will load when parsing/reading the script.

        # Above loads scene into a resource PackedScene (as something with the same name),
        # ThatPackedScene.instance() must be called to create actual Node
        var node = scene.instance();  # "scene" is the same as above, instance() returns
                                      # a tree of nodes itself
        add_child(node); # add_child is a method from this node itself
```
Remember to execute all steps above. after loading, we don't have<br/> 
to load a gain for another instance, we only load once for as     <br/>
many instances as we want                                         <br/>

Declaring scripts as a class:
```sh
# Declare the class name here
class_name ScriptName, "res://path/to/optional/icon.svg"
```
Now ScriptName is a valid node. now it can be instanced with <br/>
ScriptName.new() elsewhere


## PHYSICS
Right click physics material to make a node unique

## TROUBLESHOOTING
TO FIX UNCENTERED GAME SCREEN ON START: editor setting  >run > rect top left

## NODES
_ready() vs _init() . Ready is only called when all the     <br/> 
child nodes and itself are loaded into the scene, NOTE      <br/> 
that all childs need to be loaded first. init is like a     <br/> 
constructor                                                 <br/> 

Node._process(delta) vs Node._physics_process(delta),       <br/> 
_process is called every frame while _physics is called     <br/> 
every physics FPS(in settings), things which need to        <br/> 
be calculated before physics algos run need to be           <br/> 
_physics_process as delta in _process is unstable as it     <br/> 
depends on user hardware. They extend the actual _process   <br/> 
and _physics_process process in the class Node              <br/> 

str(var) to convert a var to string if it stored as an int<br/>

NEW Node: .new() creates a new node, you need to code it to be the child as well<br/>
```sh
    s = Sprite.new() # Create a new sprite!
    add_child(s) # Add it as a child of this node.
```

Delete Node: .free() to immediately delete node and all its children.<br/>
.queue_free() to safetly free so that we do not delete mid function call<br/>

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
SceneTree is a class managing hieracy of nodes in a scene as well as<br/>
scene themselves. So we get_tree() to get a reference to SceneTree <br/>
where we call the call_group function. It is has even more useful<br/>
methods, switching scenes quit and pausing the game!<br/>

## NOTIFICATIONS - Good to know
```sh
        func _notification(what):  # literally "what""
```
Called when object received notification.

REFERENCE NODE BY NAME<br/>
get_node(path) works by searching immediate children, it is equivalent to $<br/>
so to find a child of a child you have to :<br/>
get_node("Label/Button")  # reference by name, NOT TYPE<br/>


Very low level, it is easier to use provided virtual functions below.<br/>
OVERRIDABLE FUNCTIONS
Virtual functions (expect to be redefined in children)

```sh
                func _enter_tree():
            # When the node enters the Scene Tree, it becomes active
            # and  this function is called. Children nodes have not entered
            # the active scene yet. In general, it's better to use _ready()
            # for most cases.
            pass

        func _ready(): #NOTIFICATION_READY
            # This function is called after _enter_tree, but it ensures
            # that all children nodes have also entered the Scene Tree,
            # and became active.
            pass

        func _exit_tree():
            # When the node exits the Scene Tree, this function is called.
            # Children nodes have all exited the Scene Tree at this point
            # and all became inactive.
            pass

        func _process(delta): #NOTIFICATION_PROCESS
            # This function is called every frame.
            pass

        func _physics_process(delta):
            # This is called every physics frame.
            pass
```

###What is a scene tree?
There is an Operating System Class(OS Class) which is the only instance running at the start
Only after it load is everything else is loaded. When the class finishes initializing, it needs
to be supplied a main loop to run forever. The game starts from this main loop.

The Scene system is the game engine while the OS and servers are low level API.
The scene system provides scene tree as the main loop to run. SceneTree is automatically instanced.

Scenetree contain the root VIEWPORT, which is a child of scenetree itself. It control setting pause mode
quitting the game contains information about groups etc. Node.get_tree() can be called to access such
functionalities. root VIEWPORT accessed via get_tree().get_root() or get_node("/root"). All children of 
root VIEWPORT are drawn in, so it makes sense the top of every node needs to be of this type to be visible.
the root VIEWPORT is the only one not created by the use, it is automatically made inside scenetree.

Thus when a node is connected anyway to viewport, it is connected to scenetree. This is when _ready() and
_enter_tree() functions are called. These nodes turn from inactive to active and inherit all the things they 
need to process from root viewport and thus Scenetree.

Most node operations are done in tree order so that means the parents most of the get things like
drawing in 2d before their parent. The root node of every scene is connected to root VIEWPORT or to
any child or grandchild of it. Only after root node is added will receive the entree from top to bottom
fashion. "ready" notification is different as it only, as it only notifies when a node and all its children
are active so it must wait for that last node to receive the enter tree notification and signal back ready.

When a scene(or a section of it) is removed. Bottom up order instead.

change_scene can be used to change scenes but the game stall till the entire scene is loaded
change_scene won't work for long waiting times, and thus it's better to manually load in a loading
screen.

## SIGNALS
Signal format: _on_[EmitterNode]_[signal_name]<br/>
Signals are like interrupts, which is more efficient than polling

On Timer Node, note that giving values to void start(float time_set=-1) <br/>
if timer_set > 0 then it will  overwrite the wait time you give it.<br/>
Timer Node counts down from the initial wait time, autostart makes <br/>
this start as soon as the node entere the tree

Manual connection of signals are necceary when you instance nodes prodecurally, <br/>
they won't appear in the LHS scenetree heiracy for you to connect to

```s
<source_node>.connect(<signal_name>, <target_node>, <target_function_name>)
```
target node is the receiving node, which is often self(the currently scripted node), <br/>
function name is called

Manual creation of signals
```s
signal my_signal #create custom signal
signal my_signal(val, val2) # create custom signal with parameters

emit_signal("my_signal", foo, foo2)  # emits with parameters
```
Manualy created signals still appear under RHS NODE> SIGNALS, but always remember
when manually emitting, to emmit the correct number of arguments

## My first game
export keyword allows for the inspector (underscript variables)to set the value as well as other nodes
the value in the inspector takes precedence over the value in the script.

$ returns the relative path ofa child node from the current node, null if not found.
Equivalent to get_node();  $AnimatedSprite is get_node("AnimatedSprite")

clamp(what, min, max)

hide() and show() 

visibilitynotified2d viewport vs screen. screen is the entire screen resolution, 1920 1080 for 1080p screens.
but viewport is the a subsection of it project to the the window of the game
randomize() is equivalent to srand(), you should call it once at the main scene, all other scenes affected.

```s
export (PackedScene) var Mob # to instance a scene for use  
# need to goto inspector of this same scene to drag and
# drop the actual mob scene

$MobPath/MobSpawnLocation.offset = randi()  # when you want to access grandchild

# remember the GD script works with radians, there are sepecific functions for that with degree

Control is the basic ui element  Label and button inherit from it

FONT goes into dynamicfont > fontdata
Anchors and Margins, Anchors represented a shifter origin while margins the relative position to the anchor

autowrap for labels useful

yield($MessageTimer, "timeout") # this waits for timeout signal to be received before continueing the rest of the function
yield(get_tree().create_timer(1), "timeout")   # scene tree can also make a timer for u with custom time

str(score) # converts integer to string, must take note label.text is a string

#when we manually link a signal in godot, via export(Packedscene) we cant use the signal tab to 
#connect signals, we must manuall do it with eg
$HUD.connect("start_game", mob, "_on_start_game")
```

## Vectors
We can use vectors to make an enemy point at our character, B-A. normalizing a vector : a = a.normalized()
You MUST CHECK at that the length of the vector is not zero else crash
vector2d = vector2d.bounce(normal) to reflect a object hitting a surface, normal is the normal of the surface
dot product can be used to obtain angles between vectors, c= a.dot(b) note it returns a scalar.
```s
var AP = (P - A).normalized()
if AP.dot(fA) > 0:  # if dot product is zero then it is 90 degrees > 0 is infront and < 0 is behind.
# Look at the cos graph plot!
    print("A sees P!")

# This sets the disabled option to true as soon as possible, not immediately as it may happen
#in the middle of collsion processing 
$CollisionShape2D.set_deferred("disabled", true)
$CollisionShape2D.disabled = false;  # no need to defer because not processing anyways

```

For the enemy, we disabled masks property to disable collision between to instanced mobs

Cross product: a.cross(b) . Can be used to calculate normals to a plane/surface in 3d.
We can find the axis of rotation in 3d by taking the cross product of current facing direction
and desired destination.

Timer nodes and Position 2d nodes are used for timing and marking a position in space. 
One shot option for timer to only run once

For path2d, order of the points matter, you have to remeber if u drew clockwise or anti clockwise
Also remember to close the curve you just made (button in topright)

Followpath2d node has to be a child of path2d

Note that the first in the tree is drawn first in order, so background should be drawn before players and enemies

button shortcuts is two levels deep, so dig through each button to get the atualy setting

## Masks vs Layers
collision_layer describes the layers that the object appears in.
By default, all bodies are on layer 1.
collision_mask describes what layers the body will scan for
collisions. If an object isn’t in one of the mask layers, the
body will ignore it. By default, all bodies scan layer 1.

## TROUBLESHOOTING
If a sprite is invisible, you may have dragged and dropped it in, you need to load from godot itself using the import button.
Might be need to restart godot if the background is just black. May be a problem with amd
