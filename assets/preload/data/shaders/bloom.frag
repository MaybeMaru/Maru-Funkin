uniform float u_intensity;

void mainImage()
{
  const float numDirections = 16.0;
  float blurQuality = 4.0 * u_intensity;
  float blurSize = u_intensity * 16;
  float blurStrength = u_intensity;
  vec2 blurRadius = vec2(blurSize) / iResolution.xy;

  vec2 uv = fragCoord / iResolution.xy;
  const float twoPi = 6.28318530718;
  vec4 color = texture(iChannel0, uv);

  for (float angle = 0.0; angle < twoPi; angle += twoPi / numDirections)
  {
    for (float i = 1.0 / blurQuality; i <= 1.0; i += 1.0 / blurQuality)
    {
      float xOffset = (cos(angle) * blurSize * i) / iResolution.x;
      float yOffset = (sin(angle) * blurSize * i) / iResolution.y;
      color += texture(iChannel0, uv + vec2(xOffset, yOffset));
    }
  }

  color /= (blurStrength * blurQuality) * numDirections - 15.0;
  vec4 bloom = (texture(iChannel0, uv) / blurStrength) + color;
  fragColor = bloom * u_intensity;
}
