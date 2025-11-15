shader_type canvas_item;

// Hit flash shader for damage feedback on characters
// Interpolates between base texture and flash color

uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	// Mix base color with flash color based on flash_amount
	COLOR.rgb = mix(base.rgb, flash_color.rgb, flash_amount);
	COLOR.a = base.a;
}
