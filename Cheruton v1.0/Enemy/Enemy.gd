extends KinematicBody2D
class_name Enemy

onready var damage_val = preload("res://Enemy/DamageVal/DamageVal.tscn")
onready var hit_effect = preload("res://Effects/MobHit/HitFx.tscn")

var target_correction = Vector2( 0, -6 )

func _ready():
	call_deferred("_link_to_target_area")

func _link_to_target_area():
	var node = find_node("target_area")
	if(!node):
		return

func _highlight_target():
	pass

func _clear_target():
	pass

func display_damage(damage_value):
	var damage_text = damage_val.instance()
	damage_text.amount = damage_value
	add_child(damage_text)
