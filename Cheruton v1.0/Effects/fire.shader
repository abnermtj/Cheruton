shader_type canvas_item;

// Values updated in Shader Param
uniform vec4 transparent : hint_color;
uniform vec4 inner : hint_color;
uniform vec4 outer : hint_color;


uniform float inner_threshold = 0.4;
uniform float outer_threshold = 0.15;
uniform float soft_edge = 0.04;
uniform vec2 center = vec2(0.5, 0.8);

uniform int OCTAVE = 6;

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
	
	//Actual equation is longer
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

// Increases intensity of the image
float overlay(float base, float top){
	if(base < 0.5)
		return 2.0 * base * top;
	
	// Base > 0.5
	return 1.0 - 2.0 * (1.0 - base) * (1.0 - top);
}

// Shapes the fire like an egg
float egg_shaped(vec2 coord, float radius){
	vec2 diff = coord - center;
	
	if(coord.y < center.y)
		diff.y /= 2.0;
	else
		diff.y *= 2.0;
	
	float dist = sqrt(diff.x * diff.x + diff.y * diff.y) / radius;
	float result = clamp(1.0 - dist, 0.0, 1.0);
	return result * result;
}

void fragment() {
	vec2 coord = UV * 8.0;
	vec2 fbmcoord = coord / 6.0;
	float egg = egg_shaped(UV, 0.38);
	egg += egg_shaped(UV, 0.2) * egg_shaped(UV, 0.2);
	
	float noise1 = noise(coord + vec2(TIME * 0.25, TIME * 4.0)); 
	float noise2 = noise(coord + vec2(TIME * 0.5, TIME * 7.0));
	// Average the 2 noise
	float comb_noise = (noise1 + noise2) / 2.0;
	
	float fbm_noise = fbm(fbmcoord + vec2(0.0, TIME * 3.0));
	fbm_noise = overlay(fbm_noise, UV.y);
	
	float combination = comb_noise * fbm_noise * egg;
	if(combination < outer_threshold)
		COLOR = transparent;
	else if (combination < outer_threshold + soft_edge)  // gradient outer
		COLOR = mix(transparent, outer, (combination - outer_threshold)/soft_edge);
	else if (combination < inner_threshold)   // between outer and inner
		COLOR = outer;
	else if (combination < inner_threshold + soft_edge)  // gradient outer
		COLOR = mix(outer, inner, (combination - inner_threshold)/soft_edge);
	else
		COLOR = inner;

}
