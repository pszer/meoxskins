#pragma language glsl3

#ifdef VERTEX

vec4 position(mat4 transform, vec4 vertex) {
	return transform * vertex;
}
#endif

#ifdef PIXEL

uniform vec4 colour;

void effect( ) {
	vec4 curr_col = love_Canvases[0];

	if (curr_col.a == 0.0) {
		love_Canvases[0] = vec4(colour.xyz, 1.0);
	} else {
		love_Canvases[0] = colour;
	}
}

#endif
