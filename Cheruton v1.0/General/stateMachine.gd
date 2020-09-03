extends Node
class_name baseFSM
signal stateChanged(curState)

export(NodePath) var START_STATE
var statesDict = {}

var curState = null
var prevState = null

var isInputEnabled = false # Thus must be manualy set true in input controlled subclasses
var isFsmActive = false setget setFsmActive

# _ready() function not overridable so no need ._ready() in subclasses
func _ready():
	initializeStates()
	setStartStateAndEnter(START_STATE)
	setFsmActive(true)

func initializeStates():
	for child in get_children():
			statesDict[child.name] = child
			child.connect("changeState", self, "onChangeState")

func setStartStateAndEnter(startState):
	curState = get_node(startState)
	curState.call_deferred("enter")

func setFsmActive(value):
	isFsmActive = value
	set_physics_process(value)
	set_process(value)
	set_process_input(value)

func _physics_process(delta):
	curState.call_deferred("update", delta)

func _process(delta):
	curState.call_deferred("update_idle", delta)

func _input(event):
	curState.handle_input(event)

func _on_animation_finished(anim_name):
	if isFsmActive:
		curState._on_animation_finished(anim_name)

func onChangeState(state_name):
	if isFsmActive:
		curState.call_deferred("exit")

		prevState = curState
		curState = statesDict[state_name]
		curState.call_deferred("enter")

		emit_signal("stateChanged", curState)
