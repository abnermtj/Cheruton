extends Sprite


# Only when sprite is loaded currently
func _ready():
	material.set_shader_param("sprite_scale", scale)
