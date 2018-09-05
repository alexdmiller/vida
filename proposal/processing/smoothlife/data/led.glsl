#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
 
uniform sampler2D texture;
uniform vec2 pixelSize;
 
varying vec4 vertColor;
varying vec4 vertTexCoord;
 
const vec4 mainColor = vec4(1.0, 1.0, 1.0, 1.0);
const vec4 secondaryColor = vec4(0.0, 0.0, 1.0, 1.0);
const vec4 tertiaryColor = vec4(1.0, 0, 0, 1.0);

float sigmoid(float x, float startX, float endX) {
  if (x <= startX) return 0.0;
  else if (x >= endX) return 1.0;
  else {
    float scaledX = (x - startX) / (endX - startX);
    return 0.5 + scaledX * (1.0 - abs(scaledX) * 0.5);
  }
}

void main() {
    int si = int(vertTexCoord.s * pixelSize.s);
    int sj = int(vertTexCoord.t * pixelSize.t);
    if (si % 2 == 0 || sj % 2 == 0) {
      gl_FragColor = vec4(0, 0, 0, 0);
    } else {
      vec4 c = texture2D(texture, vec2(float(si) / pixelSize.s, float(sj) / pixelSize.t)) * vertColor;
      // gl_FragColor = sigmoid(c.x, 0.5, 1) * mainColor + sigmoid(c.y, 0, 1) * secondaryColor + sigmoid(c.z, 0, 1) * tertiaryColor;
      gl_FragColor = c.x * mainColor + c.y * secondaryColor + c.z * tertiaryColor;
    }
}
