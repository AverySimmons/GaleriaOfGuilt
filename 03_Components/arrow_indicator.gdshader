shader_type canvas_item;

uniform float size = 64.;
uniform float arrow_size = 32.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	uv.x = 1. - uv.x;
	
	float pix_x = uv.x * size;
	
	float is_arrow = step(pix_x, arrow_size);
	
	uv.y = abs(uv.y * 2. - 1.);
	
	float arrow_x = pix_x / arrow_size;
	
	float shaft_mask = 1. - step(0.5, uv.y);
	float point_mask = 1. - step(0., uv.y - arrow_x);
	
	float final_mask = shaft_mask * (1. - is_arrow) + point_mask * is_arrow;
	
	COLOR.a = final_mask * COLOR.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
