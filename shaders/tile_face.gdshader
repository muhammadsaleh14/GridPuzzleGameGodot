shader_type canvas_item;

/// Soft rounded tile face with rim light. COLOR.rgb drives the base tint from the node modulate.

uniform vec4 face_color : source_color = vec4(0.12, 0.18, 0.2, 1.0);
uniform vec4 rim_color : source_color = vec4(0.95, 0.75, 0.35, 0.55);
uniform float corner_radius = 0.18;
uniform float rim_width = 0.07;
uniform float gloss = 0.22;
uniform float enabled_glow = 0.0;

float rounded_box(vec2 uv, float radius) {
	vec2 p = abs(uv - 0.5) * 2.0;
	float r = clamp(radius, 0.01, 0.49);
	vec2 q = p - (1.0 - r);
	float outside = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
	return 1.0 - smoothstep(r, r + 0.02, outside + r);
}

void fragment() {
	float mask = rounded_box(UV, corner_radius);
	float inset = rounded_box(UV, corner_radius * 0.92);

	// Soft top gloss
	float sheen = smoothstep(0.65, 0.05, UV.y) * gloss * inset;

	// Rim
	float rim = clamp(mask - inset, 0.0, 1.0);
	rim = smoothstep(0.0, rim_width + 0.02, rim);

	vec3 col = face_color.rgb;
	col += sheen;
	col = mix(col, rim_color.rgb, rim * rim_color.a);
	col += rim_color.rgb * enabled_glow * 0.35 * inset;

	COLOR = vec4(col, face_color.a * mask);
}
