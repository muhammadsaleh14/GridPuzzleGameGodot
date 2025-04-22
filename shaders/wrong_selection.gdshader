shader_type canvas_item;
uniform float red_amount = 1.0;  // Adjust this value to control the intensity of the red tint
uniform float black_amount = 0.5;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest_mipmap;
void fragment() {
	//vec3 color = textureLod(screen_texture, UV, 0.0).rgb;
	vec4 color = texture(TEXTURE, UV);
	color.rgb -= vec3(0,black_amount,black_amount);
	//color.r += red_amount;
	COLOR = color;
	//COLOR.rgb = mix(color ,vec3(1.0, 0.0, 0.0), 0.2);
}


//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
