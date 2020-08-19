shader_type canvas_item;

uniform vec3 Color;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    COLOR = vec4(Color, color.a);
}