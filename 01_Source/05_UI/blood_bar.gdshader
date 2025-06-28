shader_type canvas_item;

uniform float fill_percent = 1.0;
uniform float pink_mix = 0.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 uv = UV;
	float real_fill = fill_percent * 0.7 + 0.05;
	
	uv.y += (sin(uv.x * 10. + TIME * 3.) * 0.01 + cos(uv.x * 10. + TIME * 5.) * 0.015) * real_fill;
	
	float mask = uv.y;
	real_fill = 1. - real_fill;
	mask = smoothstep(real_fill, real_fill + 0.01, mask);
	
	vec3 dark_red = vec3(0.25,0,0.05);
	vec3 bright_red = vec3(1,0,0.2);
	
	vec3 dark_pink = vec3(0.5,0,0.2);
	vec3 bright_pink = vec3(1,0,0.5) * 2.;
	
	vec3 dark = mix(dark_red, dark_pink, pink_mix);
	vec3 bright = mix(bright_red, bright_pink, pink_mix);
	
	float mix_mask = (uv.y * 0.7 + 0.05) / 0.73 - 1. + fill_percent;
	vec3 final_color = mix(bright, dark, mix_mask);
	
	COLOR.rgb = final_color;
	COLOR.a = COLOR.a * mask;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
