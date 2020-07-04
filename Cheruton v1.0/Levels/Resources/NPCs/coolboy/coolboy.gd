extends StaticNPC

func _ready():
	._ready()
	$AnimationPlayer.play("sweep")
