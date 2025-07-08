shader_type canvas_item;

uniform sampler2D noise;
uniform vec2 dir = vec2(1,0);
uniform vec2 player_pos = vec2(0);
uniform float strength = 0.;
uniform vec3 color1 : source_color;
uniform vec3 color2 : source_color;

uniform vec2 wind1_offset = vec2(0);
uniform vec2 wind2_offset = vec2(0);

uniform float zoom = 1.;
void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(vec2(c, s), vec2(-s, c));
	return m * v;
}

void fragment() {
	vec2 uv1 = UV;
	uv1 /= zoom;
	uv1 += player_pos / vec2(1280, 720);
	vec2 uv2 = uv1;
	uv1.x /= 2.;
	uv1 -= wind1_offset;
	
	uv2 -= wind2_offset;
	
	float noise_mask1 = texture(noise, fract(uv1/2.)).r;
	//noise_mask1 = smoothstep(0.3, 0.9, noise_mask1);
	float noise_mask2 = texture(noise, fract(uv2/2.+100.345)).r;
	//noise_mask2 = smoothstep(0.3, 0.9, noise_mask2);
	
	COLOR.a = noise_mask1 * noise_mask2 * strength * 1.5;
	COLOR.rgb = noise_mask1 * color1 + noise_mask2 * color2;
	COLOR += vec4(1,0,0,0.1) * strength;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
