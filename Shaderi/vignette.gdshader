shader_type canvas_item;

uniform float RADIUS = 0.35;
uniform float SOFTNESS = 0.25;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = vec2(0.5);

	float dist = distance(uv, center);

	// 0 in center, 1 at edges
	float mask = smoothstep(RADIUS, RADIUS + SOFTNESS, dist);

	// Black edges, transparent center
	COLOR = vec4(0.0, 0.0, 0.0, mask);
}
