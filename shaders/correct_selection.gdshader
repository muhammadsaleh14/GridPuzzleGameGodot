
shader_type canvas_item;

uniform float black_amount = 0.7;
uniform float green_amount = 0.00;  // Adjust this value to control the intensity of the red tint

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	//color -= vec4(0.0, black_amount, black_amount, 0.0);
	color.g += green_amount;
	color.rgb -= vec3(black_amount,0,black_amount);
	COLOR = color;
}
//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
