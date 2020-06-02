shader_type canvas_item;

// Values updated in Shader Param
uniform vec4 red : hint_color;
uniform vec4 yellow : hint_color;
uniform vec4 grey : hint_color;
uniform vec4 black : hint_color;

uniform vec2 center = vec2(0.5, 0.8);
//uniform vec2 sprite_scale;
uniform int OCTAVE = 4;

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

// Fractal Brownian motion
float fbm(vec2 coord){
	float val = 0.0;
	float scale = 0.5; 

	// Decrease scale by half and Incrase val
	for(int i = 0; i < OCTAVE; i++){
		val += noise(coord) * scale;
		coord *= 2.0;
		scale /= 2.0;
	}
	return val;
}

// Shapes the fire like a hyperbola
float hyperbola_shaped(vec2 coord, float radius){
	vec2 diff = coord - center;
	
	if(coord.y < center.y)
		diff.y /= 3.0;
	else
		diff.y = 0.0;
	
	float dist = (sqrt(diff.x * diff.x) - sqrt(diff.y * diff.y)) / (radius * radius);
	
	float result = clamp(dist, 0.3, 1.0);
	
	result = clamp(1.0 - dist, 0.0, 1.0);
	return result * result;
}

void fragment() {
	int increased;
	vec2 coordi = UV * 10.0;

	
	float noises1 = fbm(coordi + vec2(TIME * -0.2, TIME * 0.2));
	float noises2 = fbm(coordi + vec2(0, TIME * -0.3));
	float noises_combined = noises1 * noises2;
	
	if(noises_combined > 0.2)
		COLOR = mix(red, yellow, (noises_combined - 1.0) * 1.25 + 1.0);
	else
		COLOR = mix(yellow, red, noises_combined * 3.0);
	
	COLOR.a += 1.8;


}
