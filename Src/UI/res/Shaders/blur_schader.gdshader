shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float lod : hint_range(0.0, 5.0) = 0.0;
uniform float darken_strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
	color.rgb = mix(color.rgb, vec3(0.0), darken_strength);
	COLOR = color;
}