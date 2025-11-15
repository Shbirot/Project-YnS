shader_type canvas_item;

// Glow/emission shader for projectiles with pulsing effect
// Apply this to projectile sprites for magical glowing effects

uniform sampler2D glow_map : hint_default_white;
uniform vec4 glow_color : source_color = vec4(0.5, 0.8, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.5;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	// Sample base texture and glow map
	vec4 base = texture(TEXTURE, UV);
	vec4 glow = texture(glow_map, UV);

	// Create pulsing effect using sine wave
	float pulse = sin(TIME * pulse_speed) * 0.3 + 0.7;

	// Calculate emission based on glow map
	vec3 emission = glow.rgb * glow_color.rgb * glow_intensity * pulse;

	// Combine base color with emission
	COLOR.rgb = base.rgb + emission;
	COLOR.a = base.a;
}
