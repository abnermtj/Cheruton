shader_type canvas_item;

uniform vec2 center;
uniform float size;
uniform float sprite_warp;
x
void fragment(){
    vec2 position = UV;
    float pi = 3.14;
    float distance_to_center = distance(position, vec2(0.5, 0.5));
    float rotation_index = sprite_warp * distance_to_center * pi * sin(TIME * spin_speed); // 6 is rotation speed
    
    position -= vec2(0.5, 0.5);

    // apply rotation transformation
    mat2 rotation_matrix = mat2(vec2(sin(rotation_index), -cos(rotation_index)),
                                vec2(cos(rotation_index), sin(rotation_index)));
    position = position * rotation_matrix;

    position += vec2(0.5, 0.5);
	
	
	// used to control the size of the cricle
	vec2 offset = UV - center;
	float mask = (1.0 - smoothstep (size - 0.1, size, length(offset)));
    
    COLOR = texture(TEXTURE, position);
	COLOR *= mask;
}