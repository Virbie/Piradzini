shader_type canvas_item;

uniform float desaturate_amount = 0.35;
uniform float contrast = 0.85;
uniform float brightness = 1.05;
uniform vec3 tint : source_color = vec3(0.9, 0.95, 1.0);

void fragment() {
    vec4 col = texture(TEXTURE, UV);

    float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    col.rgb = mix(col.rgb, vec3(gray), desaturate_amount);

    col.rgb = (col.rgb - 0.5) * contrast + 0.5;

    col.rgb *= brightness;
    col.rgb *= tint;

    COLOR = col;
}
