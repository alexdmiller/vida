
#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_COLOR_SHADER

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D ppixels;
uniform bool mouseDown;
uniform bool keyDown;

uniform float outerRadius;
uniform float innerRadius;

//Conventions:
// x component = outer radius / ring
// y component = inner radius / disk
/*
   _
 /   \
|  O  |
 \ _ /
*/
const float PI = 3.14159265;
const float dt = 0.30;



// SmoothLifeL rules
uniform float b1 = 0.257;
uniform float b2 = 0.336;
uniform float d1 = 0.365;
uniform float d2 = 0.549;

uniform float alpha_n = 0.028;
uniform float alpha_m = 0.147;
/*------------------------------*/

//const float KEY_LEFT  = 37.5/256.0;
const float KEY_UP    = 38.5/256.0;
//const float KEY_RIGHT = 39.5/256.0;
const float KEY_DOWN  = 40.5/256.0;
const float KEY_SPACE  = 32.5/256.0;


// 1 out, 3 in... <https://www.shadertoy.com/view/4djSRW>
#define MOD3 vec3(.1031,.11369,.13787)
float hash13(vec3 p3) {
  p3 = fract(p3 * MOD3);
    p3 += dot(p3, p3.yzx+19.19);
    return fract((p3.x + p3.y)*p3.z);
}


/* ---------------- Sigmoid functions ------------------------------------ */

// TODO: reduce unnecessary parameters (remove arguments, use global consts)

float sigmoid_a(float x, float a, float b) {
    return 1.0 / (1.0 + exp(-(x - a) * 4.0 / b));
}

// unnecessary 
float sigmoid_b(float x, float b, float eb) {
    return 1.0 - sigmoid_a(x, b, eb);
}

float sigmoid_ab(float x, float a, float b, float ea, float eb) {
    return sigmoid_a(x, a, ea) * sigmoid_b(x, b, eb);
}

float sigmoid_mix(float x, float y, float m, float em) {
    return x * (1.0 - sigmoid_a(m, 0.5, em)) + y * sigmoid_a(m, 0.5, em);
}

/* ----------------------------------------------------------------------- */

// SmoothLifeL
float transition_function(vec2 disk_ring, float b1, float b2) {
    return sigmoid_mix(sigmoid_ab(disk_ring.x, b1, b2, alpha_n, alpha_n),
                       sigmoid_ab(disk_ring.x, d1, d2, alpha_n, alpha_n), disk_ring.y, alpha_m
                      );
}

// unnecessary (?)
float ramp_step(float steppos, float t) {
    return clamp(t-steppos+0.5, 0.0, 1.0);
}

// unnecessary
vec2 wrap(vec2 position) { return fract(position); }

// Computes both inner and outer integrals
// TODO: Optimize. Much redundant computation. Most expensive part of program.
vec2 convolve(vec2 uv, vec2 r) {
    vec2 result = vec2(0.0);
    for (float dx = -r.x; dx <= r.x; dx++) {
        for (float dy = -r.x; dy <= r.x; dy++) {
            vec2 d = vec2(dx, dy);
            float dist = length(d);
            vec2 offset = d / resolution.xy;
            vec2 samplepos = wrap(uv + offset);
            //if(dist <= r.y + 1.0) {
                float weight = texture(ppixels, samplepos).x;
              result.x += weight * ramp_step(r.y, dist) * (1.0-ramp_step(r.x, dist)); 
              
            //} else if(dist <= r.x + 1.) {
                //float weight = texture(iChannel0, uv+offset).x;
        result.y += weight * (1.0-ramp_step(r.y, dist));
            //}
        }
    }
    return result;
}

void main()
{

    vec3 color = vec3(0.0);
    
    vec2 uv =  gl_FragCoord.xy / resolution.xy;
    vec2 r = vec2(uv.x * outerRadius + innerRadius, innerRadius);

    float b1 = b1; //(sin(uv.x * 20 + time / 3) + 1) / 2 * 0.4 + 0.01;
    float b2 = b2; //(sin(uv.y * 21 + time / 5) + 1) / 2 * 0.4 + 0.01;

    // Compute inner disk and outer ring area.
    vec2 area = PI * r * r;
    area.x -= area.y;
    /* -------------------------------------*/
    
    // TODO: Cleanup.
    color = texture(ppixels, uv).xyz;
    vec2 normalized_convolution = convolve(uv.xy, r).xy / area;
    color.x = color.x + dt * (2.0 * transition_function(normalized_convolution, b1, b2) - 1.0);
    color.yz = normalized_convolution;
    color = clamp(color, 0.0, 1.0);
    
    // Set initial conditions. TODO: Move to function / cleanup
    if(time < 2 || keyDown) {
        color = vec3(hash13(vec3(gl_FragCoord.xy, time)) - texture(ppixels, uv).x + 0.5);
    }
    
    if(mouseDown) {
        float dst = length((gl_FragCoord.xy - mouse.xy));

        if(dst <= (r.x)/resolution.x) {
          color.x = step((r.y+1.5)/resolution.x, dst) * (1.0 - step(r.x/resolution.x, dst));
        }
        /*if(dst <= (r.x)/iResolution.x) {
          color.x = step((r.y+1.0)/iResolution.x, dst) * (1.0 - step((r.x-0.5)/iResolution.x, dst));
        }*/
    }
    
    
    gl_FragColor = vec4(color, 1.0);
}