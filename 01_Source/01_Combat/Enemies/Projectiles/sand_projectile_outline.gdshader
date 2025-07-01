shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 dirs[] = {vec2(1,0),vec2(-1,0),vec2(0,1),vec2(0,-1),vec2(0.7,0.7),vec2(0.7,-0.7),vec2(-0.7,0.7),vec2(-0.7,-0.7)};
	
	float mask = 0.;
	float alpha_mask = texture(TEXTURE, UV).a;
	alpha_mask = step(0.001, alpha_mask);
	
	for (int i = 0; i < 8; i++) {
		mask = max(mask, texture(TEXTURE, UV + 0.05 * dirs[i]).a);
	}
	mask = step(0.001, mask);
	
	COLOR.rgb = mix(COLOR.rgb, vec3(1,0,0), mask * (1. - alpha_mask));
	COLOR.a = max(COLOR.a, mask);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
