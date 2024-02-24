
#pragma language glsl3

varying vec3 frag_position;
varying vec3 frag_w_position;
varying vec4 dir_frag_light_pos;
varying vec4 dir_static_frag_light_pos;
varying vec3 frag_normal;
varying vec3 frag_v_normal;

#ifdef VERTEX

uniform mat4 u_view;
uniform mat4 u_model;
uniform mat4 u_proj;

attribute vec3 VertexNormal;

mat3 get_normal_matrix(mat4 skin_u) {
	return mat3(transpose(inverse(skin_u)));
}

vec4 position(mat4 transform, vec4 vertex) {
	frag_normal = normalize(get_normal_matrix(u_model) * VertexNormal);
	frag_v_normal = frag_normal;
	frag_v_normal = mat3(u_view) * frag_v_normal;

	return u_proj * u_view * u_model * vertex;
}
#endif

#ifdef PIXEL

uniform Image MainTex;
//uniform Image SkinTexture;

void effect( ) {
	vec2 f = mod(VaryingTexCoord.xy-vec2(1/2048,1/2048), vec2(1/64.0,1/64.0));
	if (f.x < 1/1024.0 || f.y < 1/1024.0 ) {
		love_Canvases[0] = vec4(0.9,0.9,0.9,0.15);
	} else {
		love_Canvases[0] = vec4(0.0,0.0,0.0,0.0);
	}
}

#endif
