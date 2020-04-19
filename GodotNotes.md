# Godot Notes
## SETTINGS
It is also possible to add custom configuration options and read. 
them in at run-time using the ProjectSettings singleton SETTINGS.  
Singleton are classes only instanced once. <br/>

## SCENES
Main scence can be defined in project settings Packed Scenes
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
Remember to execute all steps above. after loading, we don't have
to load a gain for another instance, we only load once for as     
many instances as we want                                         <br/>

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
_ready() vs _init() . Ready is only called when all the child nodes and itself are loaded into the scene, NOTE  
that all childs need to be loaded first. init is like a 
constructor                                                 <br/> 

Node._process(delta) vs Node._physics_process(delta),   
_process is called every frame while _physics is called 
every physics FPS(in settings), things which need to
be calculated before physics algos run need to be
_physics_process as delta in _process is unstable as it 
depends on user hardware. They extend the actual _process
and _physics_process process in the class Node <br/> 

str(var) to convert a var to string if it stored as an int<br/>

NEW Node: .new() creates a new node, you need to code it to be the child as well<br/>
```sh
    s = Sprite.new() # Create a new sprite!
    add_child(s) # Add it as a child of this node.
```

Delete Node: .free() to immediately delete node and all its children.
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
SceneTree is a class managing hieracy of nodes in a scene as well as
scene themselves. So we get_tree() to get a reference to SceneTree 
where we call the call_group function. It is has even more useful
methods, switching scenes quit and pausing the game!<br/>

## NOTIFICATIONS - Good to know
```sh
        func _notification(what):  # literally "what""
```
Called when object received notification.

**REFERENCE NODE BY NAME**<br/>
get_node(path) works by searching immediate children, it is equivalent to $<br/>
so to find a child of a child you have to :<br/>
get_node("Label/Button")  # reference by name, NOT TYPE<br/>


Very low level, it is easier to use provided virtual functions below.<br/>
**OVERRIDABLE FUNCTIONS** <br/>
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

### What is a scene tree?
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

On Timer Node, note that giving values to void start(float time_set=-1)
if timer_set > 0 then it will  overwrite the wait time you give it.
Timer Node counts down from the initial wait time, autostart makes 
this start as soon as the node entere the tree

Manual connection of signals are necceary when you instance nodes prodecurally,
they won't appear in the LHS scenetree heiracy for you to connect to

```s
<source_node>.connect(<signal_name>, <target_node>, <target_function_name>)
```
target node is the receiving node, which is often self(the currently scripted node),
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

'$' returns the relative path ofa child node from the current node, null if not found.
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
One shot option for timer to only run once.

For path2d, order of the points matter, you have to remeber if u drew clockwise or anti clockwise.
Also remember to close the curve you just made (button in topright).

Followpath2d node has to be a child of path2d.

Note that the first in the tree is drawn first in order, so background should be drawn before players and enemies.

Button shortcuts is two levels deep, so dig through each button to get the atualy setting.

## Masks vs Layers
collision_layer describes the layers that the object appears in.
By default, all bodies are on layer 1.
collision_mask describes what layers the body will scan for
collisions. If an object isn’t in one of the mask layers, the
body will ignore it. By default, all bodies scan layer 1.

## onready var
equivalent to assiging variable in _ready(), otherwise would result in
the value beings assigned when the script is created. Thus var cannot use expressions
related to the tree while onready var lets u assign value depending on the tree instanced in, so can use get_node (same as $)
eg.
```s
onread var child = $somechild  # this allows for not having to type long path
# another reason is that some properties are only defined when the node enters the scne eg. UI node with min_size 100px with "expand" will change depending on the scene it is instanced in
```

## Exporting games
In project settings, Emulate touch from mouse is disabled by default.
On the different strech modes, Aspect modes, and Orientation modes.
Mode,Disabled / 2d / viewprot
ASSUMING DISABLED aspect mode FOR ALL BELOW
Disabled: when the window is resized , nothing is upscaled or downscared expect gui, so the window can cut of parts now. 
2d: stretch all elements to fit the window perfectl, the original ratio dun care
Viewport: Everything is scaled to orignal relative size, so the whole thing can be squeezed and become pixellated
Aspect ratio ignore / keep /expand
Mixing this with above produced funky results. I can't understand. Best just to try
Orientation mode is the default game orientation in mobile.
TIP, import 2x higher rest sprites for the different screens resolutions and use DISABLED

Export presets, There is a export pck/zip which only exporta a packed version of project data so executable,

REMEMBER TO UPDATE export templates every update of godot.
export projects, is a complete execuatble.

tidbit, exporting on a mac os computer we have .dmg file vs on windows/linux we get a .zip file. You can set application icon for windows!

To export on andriod, refer to online :p since we not using it. There are Software Development Kits(SDKs) that you also have to download

TO export to IOS, need a MacOS (not needed to be apple) with Xcode. Need an appstore apple id into member ship section :( damn u apple!

To export html for websites, need an actaul server to run it, you can't just double click. To disable the default console, "export without debug"
## TROUBLESHOOTING
Invisible sprite and blue background due to my graphics card, try to use desktop instead.

## Learning From DeadLock
Things to know: <br/>
        SETGET
        Whenever the value of variable is modified by an external source (i.e. not from local usage in the class)
        , the setter function will be called. This happens before the value is changed.
        The setter must decide what to do with the new value.
        Vice versa, when variable is accessed (externally), the getter function must return the desired value.
        Below lets you define these functions

        ```
        var variable = value setget setterfunc, getterfunc
        var variable = value setget setterfunc  # also valid getter is ommited
        var variable = value setget ,getterfunc  # also valid setter is ommited
        ```

Overview of deadlock code structure
###Main
TOP
-First scene and menu is defined as a constant
ONREADY
-either loads the first screen or the game state
LOADING
-sets to voluem to be low
-load FIRST screen or load game state have similar sructure
5 STATE OF LOADING
0) pauses the tree fades out
1) frees all children from pervious level
2) includes all children from previous level
3) fades in
4) go back to 0
both of the above have timers for each state that on timeout will cause the next stage to occu,
A calls a time to call itself again once certain time has passed
PAUSING
-stops the tree and freezes the map by saving is current state, delete it, then passing the values
to a pause layer that holds it until unpaused hides the old layer shows the frozen one
LINE 130-135
On game pause, for anything that is part of the map, a setter function
in map_part.gd which stops all animation in animation player. Modulate function is
used to make the current map part turn the color you want 1,1,1,1 which is pure white
when the color is applied to the Texture is seems the it remains mostly the same
MODULATE IS COLOR MULTIPLICATION, NOT JUST SETTING THE COLOR. Modulate is part of CanvasItem

pausemenu.activate() is called when all of the above is done

pause_finsihed function
yield( get_tree().create_timer( 0.25 ), "timeout" ) # player given time to react to unpause
it seems a chunk of code is just dedicated to making the minimap work, when you pause it
moves and flashes the minimap form the topright to the left of the screen. And to get the main menu
to pop uo. most of the actual pausing is done by get_tree.pause(). 

_on_gamestate_change(), if else and match statements that change the HUD first, depending
on the state when the function is called. for lives, they just manually toggled

set_hud_particles, colors emmitted depending on state

MUSIC
preloads music cuz they wasting my ram

set_music() middle man function which checks if the currrent music is the music that takes in
Tracknumber, FadeIn, FaceOut, Starting Point.
no : int, means that the variable no is hinted to be type int i think its more for code clarity.
calls music fsm() if need to change

musicfsm() actual controller of music
3 stages, this function recursively calls itself.
fades out music, There is no actual code for the music, AUDIO STREAM PLAYER node handles everything.
AUDIOSTREAMPLAYER.stream to select music
AUDIOSTREAMPLAYER.play(int pos) to start track at desired position
AUDIOSTREAMPLAYER/ANIMATIONPLAYERCHILD.play( "fade_in", -1, 1.0 / fade_in )   #controls the fade in levels etc.

NOTE THE USE OF '/' to find the grandchild as $Node really is just the path of the node

use of call_defered to ensure that setting music does not abruptly change current music settings

_on_vol_pitch_control_animation_finished() calls the music fsm again, because if there is 
a pitch change, music fsm must call itself only when the pitch changing is done, before setting the next
track. note how it has an automatical function argument that is default to the signal

slow_music and level restart sound effects trivial

### PLAYER GD

CONSTANTS FOR:
 1)GRAVITY
 2)COYOTE_TIME
 3)JUMP_AGAIN_MARGIN  # input buffering
 4)TERM_VEL 
 5)SNAP_LEN 
 6)JUMP_VEL 
 7)MAX_VEL 
 8)AIR_ACCEL 
 9)REF_ATTACK_RANGE
variable to store the fsm is onready, not when the script is created.
FSM.NEW   - FSM is a class in fsm.gd where it is passed three arugements.
 the object whose state it is controlling it can be:
 1)a player/enemy object 
 2)the states parents 
 3)actual state itself 
 4)debug flag 
The parents for idle, run and jump is called STATES.
Similarily, another FSM for aiming has the parent called
AIMstate, for the different aim_idle, aim_aim under it

in FSM.gd, it prints of the number of children in the STATES and AIMSTATE or empty if none
In Gdscript, we can use strings as the index of an array, like a dictionary in python. word then meaning.
Creates an array called states for each FSM. which stores a dictionary called states that links the name of the state to 
the actual state object itself
Declares that states FSM to be "self" (the fsm that is declaring it). And declares the object that it is controlling to be the
same object as the fsm. which can be the palyer or the enemy etc

func run_machine(delta): <br/>
This function constantly checks if the next state = to the current state and if not switch to it. also says if it is the starting state
Stores the PREVIOS state as well, incase some functions need to know it. initliazes the variable which hold the path to the node of running,
idle etc. then that idle or running state node will continiously run according to the delta we pass along to it. so it is in sync with the fsm.
So every state has a init and a run function at least


## Godot game design philosophy
CollisionShape2D are an exception to nodes inheriting from those above it. Godot has hot-reloading which means
when a script is changed, only that script is reloaded(vs the entire game). This means you don't have to restart
the game to see your reflected changes "Sync scene changes" and "sync script changes"

Gdscript is like python but still offers static langauage quality autocompletion(able to infer types)
.vs files are visual scriptin files, that help you visualize connection between nodes and their properties.

MIT license, freedom and fully open source!

The Godot editor is a game! It has nodes and scenes at its core hence u can extend it using gd script as well.
The 'tool' keyword at the top of the script makes it run in the editor(remember which is a game).

The 2D engine and the 3D engine are two separate entities in Godot but you can render 3d in 2d / 2d in 3d/ overlay 2d
sprite over 3dworld

## Designing interfaces with Control Nodes
All control nodes share the same main properties:
        1)Anchor
        2)Bounding rectangle
        3)Focus and focus neighbor
        4)Size flags
        5)Margin
        6)The optional UI theme

Commonly used control nodes:
        1)Label: for displaying text
        2)TextureRect: used mostly for backgrounds, or everything that should be a static image
        3)TextureProgress: for lifebars, loading bars, horizontal, vertical or radial
        4)NinePatchRect: for scalable panels
        5)TextureButton: to create buttons
Texture rectangle: Benefits over sprite is that it has scaling options, like tiling or straight up resizing.
Texture button: like texture rectangle but 5 texture slots, one for each state of the button normal, pressed , hover...
Texture Progess: allow 3 sprites to create progress bar, one over one under and one the progresss  itself. Fill mode is the direction of the bar.
Label: you can't scale the text if autowrap is off.
Ninepatchrect: is called that beaucse the texture is split 3x3, where only the center peice is scaled (by tiling)when  scaling.

Two ways to buildin scalable and responsive UIs
        - Multiple container nodes that scale and place UI
        - Layout menu which helps you anchor, place and resize UI with its parent

Anchors are the origin of the Control node, they can be changed   
is the layout button at the top of the editor easily. Anchor      
values range from 0 to 1 . For left and top,0 means that without  
any margins(or displacement), the sprite will be flush to the     
side with 0. For the bottom and right EDGES, 1 in left and top
anchor means that they will align with bottom and right edges respectively
Anchors represent the distance from the parent container's
size(may not be the viewport)
 
Margins on the other hand refer to exact pixels from the anchor

Control nodes should always be in a container, so that they maintain their margins,and its just the anchors than move along side the container.

Control nodes have a size flag, this tells teh containers how the ui elements should scale. They have things like fill and expand which will react in certain ways whe there are multiple control nodes in the same container

Custom Constants of containers have special properties on control ui arrangment

Useful containers:
        1)MarginContainer, to add margins around part of the UI
        2)CenterContainer, to center its children in its bounding box
        3)VboxContainer and HboxContainer, to arrange UI elements in rows or columns
        4)GridContainer, to arrange Controls nodes in a grid-like pattern
size

Containers often nest into each other, UI has progress bar container, title container, button container

Breif explainantion:
Margin Containers: adds a margin to its children so that they remain separated
Center Containers all its children are cented in the bouding rectangle.
H or VBoxContainer: Automatically arranges children accordingly with gap
GridContainer:grid like container, you can only control the umbers of columns, therows will be determined by children count.
