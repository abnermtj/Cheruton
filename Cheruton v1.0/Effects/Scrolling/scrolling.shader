shader_type canvas_item;

uniform vec2 Velocity = vec2(1.0, 0.0);

void fragment(){
	COLOR = texture(TEXTURE, UV + Velocity * TIME);
}