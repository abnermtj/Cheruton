shader_type canvas_item;

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
	float egg = egg_shaped(UV, 0.4);
	
	COLOR = vec4(vec3(egg), 1.0);
}
