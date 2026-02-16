shader_type canvas_item;
uniform float vignette_intensity = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_rgb : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 uv_centered = uv - vec2(0.5);
	float vignette = length(uv_centered) * vignette_intensity;
	vignette = pow(vignette, 2.0); // Adjust softness
	
	vec4 text = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR = mix(text, vignette_rgb, vignette * vignette_opacity);
}