shader_type canvas_item;

uniform float fill_percent = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 uv = UV;
	float real_fill = fill_percent * 0.985 + 0.015;
	
	uv.y += (sin(uv.x * 10. + TIME * 2.) * 0.02 + cos(uv.x * 10. + TIME * 3.) * 0.01) * (1. - real_fill);
	
	float mask = uv.y;
	real_fill = 1. - real_fill;
	mask = smoothstep(real_fill, real_fill + 0.01, mask);
	
	vec3 dark_red = vec3(0.05,0,0.05);
	vec3 bright_red = vec3(0.2,0,0.15);
	
	float mix_mask = (uv.y * 0.7 + 0.05) / 0.73 - 1. + fill_percent;
	vec3 final_color = mix(bright_red, dark_red, mix_mask);
	
	COLOR.rgb = final_color;
	COLOR.a = COLOR.a * mask;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
