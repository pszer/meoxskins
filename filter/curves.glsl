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

	texcolor.x = redCurve[min(sampleCount-1,int(texcolor.x * float(sampleCount)))];
	texcolor.y = greenCurve[min(sampleCount-1,int(texcolor.y * float(sampleCount)))];
	texcolor.z = blueCurve[min(sampleCount-1,int(texcolor.z * float(sampleCount)))];

	float lum = clamp(calculateLuminance(texcolor.xyz),0.0,1.0);
	float scale = valueCurve[min(sampleCount-1,int(lum * float(sampleCount)))] / (lum + 0.00001);

	texcolor.xyz = clamp(texcolor.xyz*scale,0.0,1.0);

	love_Canvases[0] = vec4(texcolor.xyz,alpha);
}

#endif
