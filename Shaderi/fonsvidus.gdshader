shader_type canvas_item;
uniform float blur_radius = 0.0; // 0 = no blur
uniform float desaturate_amount = 0.35;
uniform float contrast = 0.85;
uniform float brightness = 1.05;
uniform vec3 tint : source_color = vec3(0.9, 0.95, 1.0);
void fragment() {
    vec4 col;

    // --- Blur logic ---
    if (blur_radius > 0.0) {
        vec2 pixel = TEXTURE_PIXEL_SIZE * blur_radius;
        vec4 sum = vec4(0.0);
        for(int x=-1; x<=1; x++){
            for(int y=-1; y<=1; y++){
                vec2 offset = vec2(float(x), float(y)) * pixel;
                sum += texture(TEXTURE, UV + offset);
            }
        }
        col = sum / 9.0;
    } else {
        col = texture(TEXTURE, UV);
    }

    // --- Keep your original color grading exactly as before ---
    float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    col.rgb = mix(col.rgb, vec3(gray), desaturate_amount);
    col.rgb = (col.rgb - 0.5) * contrast + 0.5;
    col.rgb *= brightness;
    col.rgb *= tint;

    COLOR = col;
}