shader_type canvas_item;

uniform vec3 colour = vec3(1.0, 1.0, 1.0); // Grey
uniform int OCTAVE = 8;


// Get alpha_val to be btw 0 and 1
// Fract: Obtains decimal val, Sin: Wavy Texture
float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(66, 78))* 1000.0) * 1000.0);
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

// Determies colors to render
void fragment(){
	vec2 coord = UV * 20.0;
	
	float moving = fbm(coord + TIME * 0.5);
	
	// Ripple Effect
	float ripple = fbm(coord + moving);
	
	COLOR = vec4(colour, ripple * 0.75);
}