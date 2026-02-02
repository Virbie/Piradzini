shader_type canvas_item;

uniform float blur : hint_range(0.0, 4.0) = 1.5;  // Slider range: from 0 to 4
uniform float darken_strength : hint_range(0.0, 1.0) = 0.5;  // Darkening strength
uniform float saturation_strength : hint_range(0.0, 1.0) = 0.5;  // Saturation strength
void fragment() {
    vec2 px = TEXTURE_PIXEL_SIZE * blur;

    vec4 c = texture(TEXTURE, UV);
    c += texture(TEXTURE, UV + vec2(px.x, 0.0));
    c += texture(TEXTURE, UV - vec2(px.x, 0.0));
    c += texture(TEXTURE, UV + vec2(0.0, px.y));
    c += texture(TEXTURE, UV - vec2(0.0, px.y));

    c /= 5.0;
    c.a = texture(TEXTURE, UV).a; // Preserve alpha
    // --- Darkening / Desaturation effect ---
    // Darken the color based on the darken_strength parameter
    float darken_factor = 1.0 - darken_strength;
    c.rgb *= darken_factor;

    // Desaturate the color based on the saturation_strength parameter
    float gray = dot(c.rgb, vec3(0.299, 0.587, 0.114));  // Convert to grayscale
    c.rgb = mix(vec3(gray), c.rgb, 1.0 - saturation_strength);  // Mix original color with grayscale

    // Preserve alpha
    c.a = texture(TEXTURE, UV).a;

    // Output the modified color
    COLOR = c;
}
