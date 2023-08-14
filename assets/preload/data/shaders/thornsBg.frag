uniform int effectType; // 0 -> Dreamy, 1 -> Wavy
uniform float uFrequency;

void mainImage()
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 pt = uv;

    float w = 1.0 / iResolution.x;
    float h = 1.0 / iResolution.y;

    // Effect parameters
    float uSpeed = 1.333;
    float uWaveAmplitude = 0.01;

    if (effectType == 0)
    {
        pt.y = floor(pt.y / h) * h;
        float offsetX = sin(pt.y * uFrequency + iTime * uSpeed) * uWaveAmplitude;
        pt.x += floor(offsetX / w) * w; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
    }
    else if (effectType == 1)
    {
        pt.x = floor(pt.x / w) * w;
        float offsetY = sin(pt.x * uFrequency + iTime * uSpeed) * uWaveAmplitude;
        pt.y += floor(offsetY / h) * h; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
    }

    uv = pt;
    fragColor = texture(iChannel0, uv);
}