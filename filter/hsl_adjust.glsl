#pragma language glsl3

#ifdef PIXEL

uniform float hueShift;
uniform float satScale;
uniform float lumScale;
uniform float lumCurvedRemap;

float calculateLuminance(vec3 color) {
    return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}

// Function to convert RGB to HSL
vec3 rgbToHsl(vec3 rgbColor) {
    float Cmax = max(max(rgbColor.r, rgbColor.g), rgbColor.b);
    float Cmin = min(min(rgbColor.r, rgbColor.g), rgbColor.b);
    float delta = Cmax - Cmin;

    float hue = 0.0;
    if (delta > 0.0) {
        if (Cmax == rgbColor.r) {
            hue = mod((rgbColor.g - rgbColor.b) / delta, 6.0);
        } else if (Cmax == rgbColor.g) {
            hue = ((rgbColor.b - rgbColor.r) / delta) + 2.0;
        } else {
            hue = ((rgbColor.r - rgbColor.g) / delta) + 4.0;
        }
        hue *= 60.0;
    }

    float lightness = (Cmax + Cmin) / 2.0;

    float saturation = 0.0;
    if (lightness > 0.0 && lightness < 1.0) {
        saturation = delta / (1.0 - abs(2.0 * lightness - 1.0));
    }

    return vec3(hue, saturation, lightness);
}

// Function to convert HSL to RGB
vec3 hslToRgb(vec3 hslColor) {
    float C = (1.0 - abs(2.0 * hslColor.z - 1.0)) * hslColor.y;
    float X = C * (1.0 - abs(mod(hslColor.x / 60.0, 2.0) - 1.0));
    float m = hslColor.z - C / 2.0;

    vec3 rgbColor;

    if (hslColor.x >= 0.0 && hslColor.x < 60.0) {
        rgbColor = vec3(C, X, 0.0);
    } else if (hslColor.x >= 60.0 && hslColor.x < 120.0) {
        rgbColor = vec3(X, C, 0.0);
    } else if (hslColor.x >= 120.0 && hslColor.x < 180.0) {
        rgbColor = vec3(0.0, C, X);
    } else if (hslColor.x >= 180.0 && hslColor.x < 240.0) {
        rgbColor = vec3(0.0, X, C);
    } else if (hslColor.x >= 240.0 && hslColor.x < 300.0) {
        rgbColor = vec3(X, 0.0, C);
    } else {
        rgbColor = vec3(C, 0.0, X);
    }

    return rgbColor + vec3(m);
}

uniform Image MainTex;

void effect( ) {
	vec4 texcolor = Texel(MainTex, VaryingTexCoord.xy);
	vec3 hsl = rgbToHsl(texcolor.xyz);

	// Hue shift
	hsl.x = mod(hsl.x + hueShift, 360.0);
	// Saturation scale
	hsl.y = clamp(hsl.y * satScale, 0.0, 1.0);
	// Lightness adjust
	if (lumCurvedRemap!=0.0) {
		hsl.z = clamp(pow(hsl.z, 1.0/max(lumScale,0.001)), 0.0, 1.0);
	} else {
		hsl.z = clamp(hsl.z * lumScale, 0.0, 1.0);
	}

	vec3 col = hslToRgb(hsl);
	love_Canvases[0] = vec4(col, texcolor.a);
}

#endif
