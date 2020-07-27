shader_type canvas_item;
void fragment(){
    vec2 position = UV;
    float pi = 3.14;
    float distance_to_center = distance(position, vec2(0.5, 0.5));
    float rotation_index = 6.0 * distance_to_center * pi * sin(TIME/20.0); // 6 is rotation speed
    
    // move to (0.5, 0.5)
    position -= vec2(0.5, 0.5);

    // apply rotation transformation
    mat2 rotation_matrix = mat2(vec2(sin(rotation_index), -cos(rotation_index)),
                                vec2(cos(rotation_index), sin(rotation_index)));
    position = position * rotation_matrix;

    // move back
    position += vec2(0.5, 0.5);
    
    COLOR = texture(TEXTURE, position);
}