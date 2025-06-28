shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV * 2. - 1.;
	
	float mask = 1. - length(uv);
	mask = smoothstep(0., 0.25, mask);
	
	COLOR.a = mask * COLOR.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
