shader_type canvas_item;

varying float frame;

void vertex() {
	// Called for every vertex the material is visible on.
	frame = INSTANCE_CUSTOM.r;
}

void fragment() {
	vec2 uv = UV;
	uv *= 0.5;
	if (frame == 0.25 || frame == 0.75) {
		uv.x += 0.5;
	}
	if (frame >= 0.5) {
		uv.y += 0.5;
	}
	
	COLOR = texture(TEXTURE, uv);
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
