#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
 
uniform sampler2D texture;
uniform vec2 textureResolution;
uniform vec2 resolution;

varying vec4 vertColor;
varying vec4 vertTexCoord;
 
const vec4 mainColor = vec4(1.0, 1.0, 1.0, 1.0);
const vec4 secondaryColor = vec4(0.0, 0.0, 1.0, 1.0);
const vec4 tertiaryColor = vec4(1.0, 0, 0, 1.0);

const float pixelBorder = 1;

float sigmoid(float x, float startX, float endX) {
  if (x <= startX) return 0.0;
  else if (x >= endX) return 1.0;
  else {
    float scaledX = (x - startX) / (endX - startX);
    return 0.5 + scaledX * (1.0 - abs(scaledX) * 0.5);
  }
}

void main() {
  float mappedX = vertTexCoord.x * textureResolution.x;
  float mappedY = vertTexCoord.y * textureResolution.y;

  int si = int(mappedX);
  int sj = int(mappedY);

  if (mod(gl_FragCoord.x, resolution.x / textureResolution.x) <= pixelBorder || mod(gl_FragCoord.y, resolution.y / textureResolution.y) <= pixelBorder) {
    gl_FragColor = vec4(0, 0, 0, 0);
  } else {
    vec4 c = texture2D(texture, vec2(float(si) / textureResolution.x, float(sj) / textureResolution.y)) * vertColor;
    // gl_FragColor = sigmoid(c.x, 0.5, 1) * mainColor + sigmoid(c.y, 0, 1) * secondaryColor + sigmoid(c.z, 0, 1) * tertiaryColor;
    gl_FragColor = c.x * mainColor + c.y * secondaryColor + c.z * tertiaryColor;
  }
}
