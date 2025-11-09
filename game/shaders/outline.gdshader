shader_type canvas_item;

// Outline shader for selection/targeting effects
// Draws a colored outline around sprites

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 5.0) = 1.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	if (base.a > 0.1) {
		// Inside sprite, show base texture
		COLOR = base;
	} else {
		// Outside sprite, check neighboring pixels for outline
		float outline = 0.0;
		vec2 pixel_size = TEXTURE_PIXEL_SIZE * outline_width;

		// Sample 8 directions
		outline += texture(TEXTURE, UV + vec2(pixel_size.x, 0.0)).a;
		outline += texture(TEXTURE, UV + vec2(-pixel_size.x, 0.0)).a;
		outline += texture(TEXTURE, UV + vec2(0.0, pixel_size.y)).a;
		outline += texture(TEXTURE, UV + vec2(0.0, -pixel_size.y)).a;
		outline += texture(TEXTURE, UV + vec2(pixel_size.x, pixel_size.y)).a;
		outline += texture(TEXTURE, UV + vec2(-pixel_size.x, pixel_size.y)).a;
		outline += texture(TEXTURE, UV + vec2(pixel_size.x, -pixel_size.y)).a;
		outline += texture(TEXTURE, UV + vec2(-pixel_size.x, -pixel_size.y)).a;

		// If any neighbor has alpha, draw outline
		if (outline > 0.0) {
			COLOR = outline_color;
		} else {
			COLOR = vec4(0.0);
		}
	}
}
