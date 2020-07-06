shader_type canvas_item;

uniform vec4 blue_colour : hint_color;

uniform vec2 sprite_scale;
uniform float scale_x = 0.68;

// Get alpha_val to be btw 0 and 1
// Fract: Obtains decimal val, Sin: Wavy Texture
float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 coord){
	vec2 import = floor(coord);
	vec2 fraction = fract(coord);
	
	float x1 = rand(import);
	float x2 = rand(import + vec2(1.0, 0.0));
	float x3 = rand(import + vec2(0.0, 1.0));
	float x4 = rand(import + vec2(1.0, 1.0));
	
	vec2 cubic = fraction * fraction * (3.0 - 2.0 * fraction);
	
	return mix(x1, x2,cubic.x) + (x3 - x1) * cubic.y * (1.0 - cubic.x) + (x4 - x2) * cubic.x * cubic.y;
}

void fragment(){
	
	vec2 noisecoord1 = UV * sprite_scale * scale_x;
	vec2 noisecoord2 = UV * sprite_scale * scale_x + 4.0;
	
	vec2 motion1 = vec2(TIME * 0.3, TIME * -0.4);
	vec2 motion2 = vec2(TIME * 0.1, TIME * 0.5);
	
	vec2 distort1 = vec2(noise(noisecoord1 + motion1), noise(noisecoord2 + motion1));
	vec2 distort2 = vec2(noise(noisecoord1 + motion2), noise(noisecoord2 + motion2));
	
	// Subtract 1 to match background, divide by distortion scale
	vec2 distort_sum = (distort1 + distort2 - vec2(1.0)) / 60.0;
	// More distort coord, more detail
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV + distort_sum, 0);
	
	color = mix(color, blue_colour, 0.3);
	color.rgb = mix(vec3(0.5), color.rgb, 1.4);
//	color.rgb *=  1.2;
	
	// Set Surface
	float near_top = (UV.y + distort_sum.y) / (0.2/sprite_scale.y);
	near_top =  1.0 - clamp(near_top, 0, 1.0);

	color = mix(color, vec4(1.0), near_top);
	
	float edge_lower = 0.6;
	float edge_upper = edge_lower + 0.1;
	
	// Make the layer above the ripple transparent
	if(near_top > edge_lower){
		color.a = 0.0;
		
		if(near_top < edge_upper)//Interpolate alpha value
			color.a = (edge_upper - near_top) / (edge_upper - edge_lower);
	}
	COLOR = color;
}