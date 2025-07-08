shader_type canvas_item;

const vec3 blood_color = vec3(.77, 0., .0);
uniform float blood_scale : hint_range(.1, 5., .1);
uniform float blood_intensity : hint_range(0.0, 1.0);
uniform float res_x_over_y = 0;
uniform float hit_flash = 0;
uniform float red_amount = 0.;
uniform vec4 modulate: source_color = vec4(1);
// use offsets only if blood_scale > 2 or higher
uniform float offset_x : hint_range(0.0, 1.0, 0.1);
uniform float offset_y : hint_range(0.0, 1.0, 0.1);

uniform sampler2D bloodmask;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float intensity = blood_intensity + .3;

	vec2 uv = UV;
	uv.x *= res_x_over_y;
	uv = fract(uv);

	vec4 col = texture(TEXTURE, UV);
	float alpha = col.a;
	vec2 blood_offset = vec2(offset_x, offset_y);

	vec4 blood = vec4(0,0,0,1.);
	blood.r = texture(bloodmask, fract((uv + blood_offset) / blood_scale)).r - 1. + intensity;
	if (blood.r < .3) blood.r = 0.0;
	blood.r *= 8.;
	blood.r = floor(blood.r) / 5.;

	col = mix(col, blood, blood.r * 0.7);
	col.a = alpha;

	float al = COLOR.a;
	COLOR = col * (1. + hit_flash * vec4(39,2.7,31,1));
	COLOR.rgb = mix(COLOR.rgb, vec3(1,0,0), red_amount);
	COLOR.a *= al;
	COLOR *= modulate;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
