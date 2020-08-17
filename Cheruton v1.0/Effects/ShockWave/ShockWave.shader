shader_type canvas_item;

uniform vec2 center; 
uniform float strength;
uniform float size;
uniform float thickness;
uniform float chrome_abberation_offset; 

void fragment(){
	float ratio = SCREEN_PIXEL_SIZE.x/ SCREEN_PIXEL_SIZE.y;
	vec2 scaled_uv = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
	
	vec2 offset = scaled_uv - center;
	float mask = (1.0 - smoothstep (size - 0.1, size, length(offset))) * 
	   smoothstep(size-thickness-0.1, size - thickness, length(offset)); // values closer to a donut shape will be closer to 1 and further from the donut close to 0.
	vec2 displacement = normalize(offset) * strength * mask;
	
	COLOR = vec4(texture(SCREEN_TEXTURE, SCREEN_UV - displacement - chrome_abberation_offset * mask).r,
		texture(SCREEN_TEXTURE, SCREEN_UV - displacement).g,
		texture(SCREEN_TEXTURE, SCREEN_UV - displacement + chrome_abberation_offset * mask).b,
		1.0); 

//	COLOR = vec4( texture(SCREEN_TEXTURE, SCREEN_UV + offset * mask).r, 
//	texture(SCREEN_TEXTURE, SCREEN_UV).g,
//	texture(SCREEN_TEXTURE, SCREEN_UV - offset * mask).b, 1.0);
}