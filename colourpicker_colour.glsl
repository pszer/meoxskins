#pragma language glsl3

#ifdef VERTEX

vec4 position(mat4 transform, vec4 vertex) {
	return transform * vertex;
}
#endif

#ifdef PIXEL

uniform vec3 colour;

void effect( ) {
	love_Canvases[0] = vec4(colour, 1.0);
}

#endif
