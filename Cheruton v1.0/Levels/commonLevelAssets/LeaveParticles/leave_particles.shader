shader_type particles;

uniform vec4 color_1 : hint_color = vec4( 1.0 );
uniform vec4 color_2 : hint_color = vec4( 1.0 );
uniform vec4 color_3 : hint_color = vec4( 1.0 );
uniform vec4 color_4 : hint_color = vec4( 1.0 );

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void vertex() {
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	

	if (RESTART) 
	{
		TRANSFORM[3].x = rand_from_seed( alt_seed ) * 30.0 - 15.0;
		TRANSFORM[3].y = rand_from_seed( alt_seed ) * 30.0 - 15.0;
		VELOCITY.x = rand_from_seed( alt_seed ) * ( -10.0 );
		VELOCITY.y = rand_from_seed( alt_seed ) * ( 10.0 );
		
		int color_index = int( rand_from_seed( alt_seed ) * 4.0 );
		if( color_index == 0 )
		{
			COLOR = color_1;
		}
		else if( color_index == 1 )
		{
			COLOR = color_2;
		}
		else if( color_index == 2 )
		{
			COLOR = color_3;
		}
		else if( color_index == 3 )
		{
			COLOR = color_4;
		}
	} 
	else
	{
		CUSTOM.x += DELTA;
		TRANSFORM[0] = vec4(cos(CUSTOM.x), -sin(CUSTOM.x), 0.0, 0.0);
		TRANSFORM[1] = vec4(sin(CUSTOM.x), cos(CUSTOM.x), 0.0, 0.0);
	}
}

