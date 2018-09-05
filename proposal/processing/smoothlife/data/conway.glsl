// Conway's game of life

#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_COLOR_SHADER

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D ppixels;
uniform bool mouseDown;

uniform float ra;

// based on <https://git.io/vz29Q>
// ---------------------------------------------
// smoothglider (discrete time stepping 2D)

const float rr = 3.0;          // ratio of radii (3)
const float b1 = 0.257;        // birth1
const float b2 = 0.336;        // birth2
const float s1 = 0.365;        // survival1
const float s2 = 0.649;        // survival2
const float alpha_n = 0.028;   // sigmoid width for outer fullness
const float alpha_m = 0.147;   // sigmoid width for inner fullness
// ---------------------------------------------

float sigma1(float x,float a,float alpha) 
{ 
    return 1.0 / ( 1.0 + exp( -(x-a)*4.0/alpha ) );
}

float sigma2(float x,float a,float b,float alpha)
{
    return sigma1(x,a,alpha) 
        * ( 1.0-sigma1(x,b,alpha) );
}

float sigma_m(float x,float y,float m,float alpha)
{
    return x * ( 1.0-sigma1(m,0.5,alpha) ) 
        + y * sigma1(m,0.5,alpha);
}

// the transition function
// (n = outer fullness, m = inner fullness)
float s(float n,float m)
{
    return sigma2( n, sigma_m(b1,s1,m,alpha_m), 
        sigma_m(b2,s2,m,alpha_m), alpha_n );
}

float ramp_step(float x,float a,float ea)
{
    return clamp((x-a)/ea + 0.5,0.0,1.0);
}

// 1 out, 3 in... <https://www.shadertoy.com/view/4djSRW>
#define MOD3 vec3(.1031,.11369,.13787)
float hash13(vec3 p3) {
  p3 = fract(p3 * MOD3);
    p3 += dot(p3, p3.yzx+19.19);
    return fract((p3.x + p3.y)*p3.z);
}

void main()
{
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    
    float ra = (sin(uv.x * 1));
    
    // inner radius:
    float rb = ra/rr;
    // area of annulus:
    const float PI = 3.14159265358979;
    float AREA_OUTER = PI * (ra*ra - rb*rb);
    float AREA_INNER = PI * rb * rb;
    
    // how full are the annulus and inner disk?
    float outf = 0.0, inf = 0.0;
    for(float dx=-ra; dx<=ra; dx++) for(float dy=-ra; dy<=ra; dy++)
    {
        float r = sqrt(float(dx*dx + dy*dy));
        vec2 txy = mod((gl_FragCoord.xy + vec2(dx,dy)) / resolution.xy, 1.);
        float val = texture(ppixels, txy).x; 
        inf  += val * ramp_step(-r,-rb,1.0);
        outf += val * ramp_step(-r,-ra,1.0) 
                    * ramp_step(r,rb,1.0);
    }
    outf /= AREA_OUTER; // normalize by area
    inf /= AREA_INNER; // normalize by area
    
    float c = s(outf,inf); // discrete time step
    if(time < 2)
      c = hash13(vec3(gl_FragCoord.xy,time)) * 0.5;



    gl_FragColor = vec4(c,c,c,1);
}