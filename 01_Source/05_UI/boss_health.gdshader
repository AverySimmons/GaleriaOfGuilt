shader_type canvas_item;

uniform float fill_percent = 1.;
uniform float fill2_percent = 1.;
uniform vec3 bar_color : source_color = vec3(1);
uniform vec3 bar2_color : source_color = vec3(0.5);
uniform vec3 back_color : source_color = vec3(0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	uv.x = 1. - uv.x;
	
	uv.x = (uv.x + 0.21);
	
	float real_fill = fill_percent * 0.755 + 0.235;
	float real2_fill = fill2_percent * 0.755 + 0.235;
	float fill_mask = step(uv.x, real_fill);
	float fill2_mask = step(uv.x, real2_fill);
	
	vec3 col = mix(bar_color, bar2_color, fill2_mask - fill_mask);
	col = mix(back_color, col, max(fill_mask, fill2_mask));
	
	COLOR.rgb = col;
	COLOR.a = COLOR.a * max(fill_mask, fill2_mask) + COLOR.a;
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
