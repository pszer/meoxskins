#pragma language glsl3

#ifdef VERTEX

vec4 position(mat4 transform, vec4 vertex) {
	return transform * vertex;
}
#endif

#ifdef PIXEL

uniform Image MainTex;
uniform float hue;

float calculateLuminance(vec3 color) {
    return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}

void effect( ) {
	vec4 texcolor = Texel(MainTex, VaryingTexCoord.xy);
	if (texcolor.a==0.0) { discard; }
	float lum = calculateLuminance(texcolor.xyz);
	love_Canvases[0] = vec4(lum,lum,lum, 1.0) * VaryingColor;
}

#endif
