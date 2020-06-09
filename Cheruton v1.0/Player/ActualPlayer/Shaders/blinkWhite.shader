shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    COLOR = vec4(1, 1, 1, color.a);
}