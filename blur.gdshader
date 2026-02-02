shader_type canvas_item;

uniform float blur : hint_range(0.0, 4.0) = 1.5;  // Slider range: from 0 to 4

void fragment() {
    vec2 px = TEXTURE_PIXEL_SIZE * blur;

    vec4 c = texture(TEXTURE, UV);
    c += texture(TEXTURE, UV + vec2(px.x, 0.0));
    c += texture(TEXTURE, UV - vec2(px.x, 0.0));
    c += texture(TEXTURE, UV + vec2(0.0, px.y));
    c += texture(TEXTURE, UV - vec2(0.0, px.y));

    c /= 5.0;
    c.a = texture(TEXTURE, UV).a; // Preserve alpha

    COLOR = c;
}
