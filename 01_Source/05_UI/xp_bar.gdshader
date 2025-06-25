shader_type canvas_item;

uniform float fill_percent = 0.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	float real_fill = 1. - fill_percent;
	COLOR.a = COLOR.a * smoothstep(real_fill-0.01, real_fill, 1. - UV.x);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
