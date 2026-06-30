shader_type canvas_item;

uniform float radius = 50;

void fragment() {
	vec2 uv = SCREEN_UV;  // Get the UV position
	vec2 size = vec2(1.0, 1.0);  // Assuming the texture takes the full space of the rect

	// Calculate the distance from the edges
	float dist_x = min(uv.x, size.x - uv.x);
	float dist_y = min(uv.y, size.y - uv.y);
	float dist = min(dist_x, dist_y);

	// Apply the rounding effect, discard pixels that are outside the radius
	if (dist < radius) {
		float edge_dist = length(vec2(dist_x, dist_y));
		if (edge_dist < radius) {
			discard;
		}
	}
}
