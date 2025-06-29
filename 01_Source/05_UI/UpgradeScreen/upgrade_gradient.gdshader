shader_type canvas_item;

uniform vec3 color : source_color = vec3(0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV * 2. - 1.;



	float mask = 1. - (length(uv - vec2(0.75,-1)) * 0.4);
	COLOR.rgb += 0.6 * mask * color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
