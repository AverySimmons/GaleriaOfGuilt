shader_type canvas_item;

uniform float z = 0.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV * 2. - 1.;
	float circ_dist = length(uv);
	circ_dist = smoothstep(0.5 - z / 450., 1., circ_dist);
	
	COLOR.a = (1. - circ_dist) * COLOR.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
