shader_type canvas_item;

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(vec2(c, s), vec2(-s, c));
	return m * v;
}

uniform float line_amount = 2.;
uniform float perc = 0.;
uniform float rot = 0.;
uniform float offset = 0.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 uv = UV;
	uv = uv * 2. - 1.;
	uv = rotate(uv, rot);
	uv = uv * 0.5 + 0.5;
	
	uv.y += offset;
	
	uv.y = uv.y * 2. - 1.;
	vec2 uv2 = uv;
	uv2.y += 1. / (line_amount * 2.);
	uv2.x = 1. - uv.x;
	
	uv.y = fract(uv.y * line_amount) * 2. - 1.;
	uv2.y = fract(uv2.y * line_amount) * 2. - 1.;
	
	float line_dist = (1. - abs(uv.y));
	float line_mask = step(0.5, line_dist) * step(uv.x, perc * 1.5 - 0.2);
	line_dist /= 2.;
	
	float line_dist2 = (1. - abs(uv2.y));
	float line_mask2 = step(0.5, line_dist2) * step(uv2.x, perc * 1.5 - 0.2);
	line_dist2 /= 2.;
	
	vec3 col1 = vec3(0.1,0.,0.05);
	vec3 scol1 = vec3(1.,0.6,0.8) + 0.3;
	
	vec3 col2 = vec3(0.05,0.,0.1);
	vec3 scol2 = vec3(1.,0,0.3) + 0.3;
	
	vec3 c1 = mix(col1, scol1, line_dist);
	vec3 c2 = mix(col2, scol2, line_dist2);
	
	COLOR.rgb = c1 * line_mask + c2 * line_mask2;
	
	COLOR.rgb = floor(COLOR.rgb * 16.) / 16.;
	
	COLOR.a = line_mask + line_mask2;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
