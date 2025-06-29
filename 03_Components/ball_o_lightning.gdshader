shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV * 2. - 1.;
	
	float circ_mask = length(uv) - 0.98;
	
	
	float outline_mask = abs(circ_mask);
	outline_mask = step(outline_mask, 0.02);
	
	circ_mask = step(circ_mask, 0.);
	
	COLOR.a = outline_mask + 0.5 * circ_mask;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
