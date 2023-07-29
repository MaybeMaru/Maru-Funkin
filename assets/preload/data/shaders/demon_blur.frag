uniform float u_size;
uniform float u_alpha;

void mainImage()
{
    vec2 uv = fragCoord / iResolution.xy;
    vec4 blur = vec4(0.0, 0.0, 0.0, 0.0);
    float a_size = u_size * 0.05 * uv.y;
    for (float i = -a_size; i < a_size; i += 0.001) {
        blur.rgb += texture(iChannel0, uv + vec2(0.0, i)).rgb / (1600.0 * a_size);
    }
    vec4 color = texture(iChannel0, uv);
    fragColor = color + u_alpha * (color * (color + blur * 1.5 - 1.0));
}