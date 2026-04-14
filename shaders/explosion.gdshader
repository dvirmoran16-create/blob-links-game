shader_type canvas_item;

uniform sampler2D tex_1;
uniform sampler2D tex_2;
uniform bool has_second_texture = false;
uniform float fade_factor : hint_range(0.0, 1.0) = 0.0;
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	if (has_second_texture) {
		vec4 color1 = texture(tex_1, UV);
	    vec4 color2 = texture(tex_2, UV);
		COLOR = mix(color1, color2, progress);
	}
	else {
		COLOR = texture(tex_1, UV);
	}
	
	if (fade_factor > 0.0) {
		COLOR.a *= (1.0 - fade_factor * progress);
	}
}
