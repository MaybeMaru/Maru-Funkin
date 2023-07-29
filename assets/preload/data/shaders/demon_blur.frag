uniform float u_size;
uniform float u_alpha;

void main() {
	vec2 uv = openfl_TextureCoordv.xy;
	vec4 blur = vec4(0.0, 0.0, 0.0, 0.0);
	float a_size = u_size * 0.05 * openfl_TextureCoordv.y;
	for (float i = -a_size; i < a_size; i += 0.001) {blur.rgb += flixel_texture2D(bitmap, uv + vec2(0.0, i)).rgb / (1600.0 * a_size);}
	vec4 color = flixel_texture2D(bitmap, uv);
	gl_FragColor = color + u_alpha * (color * (color + blur * 1.5 - 1.0));
}
