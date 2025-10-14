#pragma language glsl3

#ifdef VERTEX

vec4 position(mat4 transform, vec4 vertex) {
	return transform * vertex;
}
#endif

#ifdef PIXEL

uniform vec4 colour;
uniform bool alphaLock;
uniform Image target;

vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord) {
	vec4 curr_col = Texel(target, pixcoord.xy/64.0);
	if (curr_col.a <= 0.0) {
		if (alphaLock) {
			return curr_col;
		} else {
			return vec4(colour.xyz, 1.0);
		}
	} else {
		return colour;
	}
}

#endif
