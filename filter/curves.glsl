#pragma language glsl3

#ifdef PIXEL

const int sampleCount = 256;

uniform float valueCurve[sampleCount];
uniform float redCurve[sampleCount];
uniform float greenCurve[sampleCount];
uniform float blueCurve[sampleCount];

float calculateLuminance(vec3 color) {
    return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}

uniform Image MainTex;

void effect( ) {
	vec4 texcolor = Texel(MainTex, VaryingTexCoord.xy);
	float alpha = texcolor.a;
	//texcolor = clamp(texcolor, 0.0, 1.0);

	texcolor.x = redCurve[int(texcolor.x * float(sampleCount))-1];
	texcolor.y = greenCurve[int(texcolor.y * float(sampleCount))-1];
	texcolor.z = blueCurve[int(texcolor.z * float(sampleCount))-1];

	float lum = clamp(calculateLuminance(texcolor.xyz),0.0,1.0);
	//float lum = max(max(texcolor.x,texcolor.y),texcolor.z);
	float scale = valueCurve[int(lum * float(sampleCount))-1] / (lum + 0.001);

	texcolor.xyz = clamp(texcolor.xyz,0.0,1.0) * scale;

	love_Canvases[0] = vec4(texcolor.xyz,alpha);
}

#endif
