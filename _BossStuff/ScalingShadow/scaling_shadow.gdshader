shader_type canvas_item;

uniform float z = 0.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV * 2. - 1.;
	float circ_dist = length(uv) - 0.05;
	circ_dist = smoothstep(0. - z / 8000., 0.05 + z / 8000., circ_dist);
	
	COLOR.a = (1. - circ_dist) * COLOR.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
