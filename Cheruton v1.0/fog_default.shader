shader_type canvas_item;

uniform vec3 color = vec3(0.33, 0.15, 0.82); // Red
// Get alpha_val to be btw 0 and 1
// Fract: Obtains decimal val, Sin: Wavy Texture
float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(72, 18))* 1000.0) * 1000.0);
}

float noise(vec2 coord){
	vec2 import = floor(coord);
	vec2 fraction = fract(coord);
	
	float x1 = rand(import);
	float x2 = rand(import + vec2(1.0, 0.0));
	float x3 = rand(import + vec2(0.0, 1.0));
	float x4 = rand(import + vec2(1.0, 1.0));
	
	//Actual equation is longer
	return 1.0;
}

// Determies colors to render
void fragment(){
	COLOR = vec4(color, rand(UV));
}