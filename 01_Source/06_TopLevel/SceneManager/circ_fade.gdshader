shader_type canvas_item;

uniform float perc = 0.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV * 2. - 1.;
	float mask = length(uv) - (1. - perc) * 3.;
	mask = smoothstep(-1., 0.0, mask);
	
	COLOR.a = mask;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
