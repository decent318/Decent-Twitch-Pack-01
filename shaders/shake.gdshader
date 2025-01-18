shader_type canvas_item;

uniform float dist = 0;
uniform float speed = 0.01;

void vertex() {
	UV.x += sin(TIME * speed) * dist;
	UV.y += sin(TIME * speed) * dist;
}