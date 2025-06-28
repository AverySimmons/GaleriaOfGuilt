shader_type canvas_item;

uniform float strength = 0.0;
uniform float pink_mix = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV * 2. - 1.;
	
	float mask = (length(uv) - 0.6) * (0.5 *  strength);
	
	vec3 color = mix(vec3(1,0,0),vec3(1,0,0.65),pink_mix);
	
	COLOR.rgb = color;
	COLOR.a = mask;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
