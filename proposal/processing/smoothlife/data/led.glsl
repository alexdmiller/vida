#version 110

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform vec2 screenResolution;
uniform vec2 renderResolution;

varying vec4 vertColor;
varying vec4 vertTexCoord;
 
const vec4 mainColor = vec4(0.0, 1.0, 1.0, 1.0);
const vec4 secondaryColor = vec4(0.5, 0.1, 0.0, 1.0);
const vec4 tertiaryColor = vec4(0.5, 0, 0.5, 1.0);

const float pixelBorder = 0.0;

float sigmoid(float x, float startX, float endX) {
  if (x <= startX) return 0.0;
  else if (x >= endX) return 1.0;
  else {
    float scaledX = (x - startX) / (endX - startX);
    return 0.5 + scaledX * (1.0 - abs(scaledX) * 0.5);
  }
}

void main() {
  vec2 uv = gl_FragCoord.xy / renderResolution;
  // 0...1 coordinates in texture
  vec2 screenPos = floor(uv * screenResolution) / screenResolution;

  if (mod(gl_FragCoord.x, renderResolution.x / screenResolution.x) <= pixelBorder || mod(gl_FragCoord.y, renderResolution.y / screenResolution.y) <= pixelBorder) {
    gl_FragColor = vec4(0, 0, 0, 0);
  } else {
    // gl_FragColor = sigmoid(c.x, 0.5, 1) * mainColor + sigmoid(c.y, 0, 1) * secondaryColor + sigmoid(c.z, 0, 1) * tertiaryColor;
    vec4 c = texture2D(texture, screenPos);
    gl_FragColor = c.x * mainColor + c.y * secondaryColor + c.z * tertiaryColor;
  }
}
