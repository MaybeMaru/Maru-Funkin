// Source: https://www.shadertoy.com/view/MlscRf

float scale = 0.8;
vec4 c = vec4(0.2124,0.7153,0.0722,0.0);

vec4 bleach(vec4 p, vec4 m, vec4 s)  {
    vec4 a = vec4(1.0);
 	vec4 b = vec4(2.0);
	float l = dot(m,c);
	float x = clamp((l - 0.45) * 10.0, 0.0, 1.0);
	vec4 t = b * m * p;
	vec4 w = a - (b * (a - m) * (a - p));
	vec4 r = mix(t, w, vec4(x) );
	return mix(m, r, s);
}

void mainImage() {
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec4 p = texture(iChannel0,uv);
	vec4 k = vec4(vec3(dot(p,c)),p.a);
	fragColor = bleach(k, p, vec4(scale));
}