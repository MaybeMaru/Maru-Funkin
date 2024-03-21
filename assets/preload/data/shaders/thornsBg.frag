uniform int effectType; // 0 -> Dreamy, 1 -> Wavy
uniform float uFrequency;

void mainImage()
{
    vec2 pt = fragCoord / iResolution.xy;

    float w = 1.0 / iResolution.x;
    float h = 1.0 / iResolution.y;

    // Effect parameters
    float uSpeed = 1.333;
    float uWaveAmplitude = 0.01;

    if (effectType == 0)
    {
        pt.y = floor(pt.y / h) * h;
        float offsetX = sin(pt.y * uFrequency + iTime * uSpeed) * uWaveAmplitude;
        pt.x += floor(offsetX / w) * w;
    }
    else if (effectType == 1)
    {
        pt.x = floor(pt.x / w) * w;
        float offsetY = sin(pt.x * uFrequency + iTime * uSpeed) * uWaveAmplitude;
        pt.y += floor(offsetY / h) * h;
    }

    vec4 c = texture(bitmap, pt);
    
    if (openfl_Alphav != 1)
    {
        fragColor = vec4(c.rgb * c.a * openfl_Alphav, c.a * openfl_Alphav);
    }
    else
    {
        fragColor = c;
    }
}