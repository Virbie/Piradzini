shader_type canvas_item;

uniform float blur_radius = 1.0; // in screen pixels

void fragment() {
    vec2 pixel = SCREEN_PIXEL_SIZE * blur_radius;
    vec4 col = vec4(0.0);

    col += texture(SCREEN_TEXTURE, SCREEN_UV + pixel * vec2(-1.0, -1.0));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + pixel * vec2( 0.0, -1.0));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + pixel * vec2( 1.0, -1.0));

    col += texture(SCREEN_TEXTURE, SCREEN_UV + pixel * vec2(-1.0,  0.0));
    col += texture(SCREEN_TEXTURE, SCREEN_UV);
    col += texture(SCREEN_TEXTURE, SCREEN_UV + pixel * vec2( 1.0,  0.0));

    col += texture(SCREEN_TEXTURE, SCREEN_UV + pixel * vec2(-1.0,  1.0));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + pixel * vec2( 0.0,  1.0));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + pixel * vec2( 1.0,  1.0));

    COLOR = col / 9.0;
}