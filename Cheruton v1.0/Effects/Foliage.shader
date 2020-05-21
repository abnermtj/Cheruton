shader_type canvas_item;

uniform vec4 blue_colour : hint_color;

uniform vec2 sprite_scale;
uniform float scale_x = 0.3;

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
	
	
	
	vec2 noisecoord1 = UV * sprite_scale * scale_x / 2.0;
	vec2 noisecoord2 = UV * sprite_scale * scale_x  + 4.0;
	
	vec2 motion1 = vec2(TIME * 0.3, TIME * -0.04);
	vec2 motion2 = vec2(TIME * 0.1, TIME * 0.05);
	
	vec2 distort1 = vec2(noise(noisecoord1 + motion1), noise(noisecoord2 + motion1));
	vec2 distort2 = vec2(noise(noisecoord1 + motion2), noise(noisecoord2 + motion2));
	
	// Subtract 1 to match background, divide by distortion scale
	vec2 distort_sum = (distort1 + distort2 - vec2(1.0)) / 60.0;
	// More distort coord, more detail
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV + distort_sum, 0);

	COLOR = color;
}