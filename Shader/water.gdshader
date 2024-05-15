shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : source_color, hint_screen_texture, filter_nearest;

uniform sampler2D noise;
uniform vec3 color;
uniform float mix_amount = 0.5;

void vertex() {

}

void fragment() {
	// Called for every pixel the material is visible on.
	//vec3 original = texture(screen_texture, SCREEN_UV).rgb;
	vec3 noise_col = texture(noise, SCREEN_UV).rgb;
	vec3 color_mix = mix(color, noise_col, mix_amount);
	ALBEDO = color_mix;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
