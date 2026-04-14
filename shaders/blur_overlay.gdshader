shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform vec4 overlay_color : source_color = vec4(0.0, 0.0, 0.0, 0.7);

void fragment() {
	vec2 screen_uv = SCREEN_UV;
	vec4 color = vec4(0.0);
	
	// Simple box blur
	float blur_size = blur_amount / 1000.0;
	int samples = 9;
	
	// Sample surrounding pixels
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			vec2 offset = vec2(float(x), float(y)) * blur_size;
			color += texture(screen_texture, screen_uv + offset);
		}
	}
	
	color /= float(samples);
	
	// Mix with overlay color
	COLOR = mix(color, overlay_color, overlay_color.a);
}