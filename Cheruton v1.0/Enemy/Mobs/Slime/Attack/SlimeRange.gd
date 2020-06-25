extends KinematicBody2D

const SPEED = 10

onready var player = get_parent().get_node("player")

var velocity = Vector2(0,0)


func _physics_process(delta):
	
	var colliders = move_and_collide(velocity)
	if(colliders):
		var hit_id = colliders.collider
		self.queue_free()
		if(hit_id.has_method("handle_enemy_attack_collision")):
			hit_id.handle_enemy_attack_collision()


func _on_SlimeRange_visibility_changed():
	if(self.visible):
		print(10001)
		velocity = global_position.direction_to(player.global_position) * SPEED
