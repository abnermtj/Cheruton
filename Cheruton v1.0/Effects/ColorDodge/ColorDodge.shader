shader_type canvas_item;

uniform sampler2D mask : hint_albedo;

void fragment(){
	vec4 under_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0);
	vec4 sprite_color = texture(mask, UV);
	
	vec4 mid_color = under_color / (vec4(1,1,1,1) - sprite_color);
	
	
	mid_color = clamp(mid_color, vec4(0,0,0,0), vec4(1,1,1,1));
	
	mid_color.a = 1.0;

	COLOR = mid_color;
}
