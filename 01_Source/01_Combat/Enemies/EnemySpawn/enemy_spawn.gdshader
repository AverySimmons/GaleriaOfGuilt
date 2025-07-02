shader_type canvas_item;

uniform float perc = 0.;
uniform sampler2D noise;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV * 2. - 1.;
	
	float circ_mask = length(uv) - perc * 0.5;
	circ_mask = smoothstep(circ_mask, circ_mask + 0.1, 0.);
	
	float fade_mask = (1. - length(uv)) * perc;
	fade_mask = max(fade_mask, 0);
	
	vec2 polar_uv = uv;
	polar_uv *= 0.5;
	polar_uv = vec2(sqrt(polar_uv.x * polar_uv.x + polar_uv.y * polar_uv.y), atan(polar_uv.y, polar_uv.x));
	polar_uv.x += TIME*0.8;
	polar_uv = fract(polar_uv);
	float noise_mask = texture(noise, polar_uv).r;
	noise_mask = smoothstep(0.4, 1., noise_mask);
	
	COLOR.a = (noise_mask * fade_mask + circ_mask) * COLOR.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
