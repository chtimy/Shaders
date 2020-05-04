#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

out vec4 outColor;

#define TWO_PI 6.28318530718

uniform vec2 iResolution;
uniform vec2 iMouse;
uniform float iTime;
uniform float iTimeDelta;

float plot(float x, float y)
{
	return smoothstep(y-0.01, y, x) - smoothstep(y, y+0.01, x);
}

float circle(vec2 origin, vec2 uv, float radius, float transition)
{
	float dist = distance(origin, uv);
	return smoothstep(radius-transition, radius+transition, dist);
}

void main( )
{
// Spatial coordinates
	vec2 uv = gl_FragCoord.xy-iResolution.xy*0.5;
// Normalized pixel coordinates (from 0 to 1)
	vec2 uvn = gl_FragCoord.xy/iResolution.xx;
    float ar = iResolution.y/iResolution.x;
    
    vec3 color = vec3(1.0, 0.0, 0.0);
    
    vec2 st = uvn * 2. - 1.;
    
    float d = length(abs(st)-0.5);    
    //d = length(min(abs(st)-0.5, 0.));   
    //d = length(max(abs(st)-0.2, 0.));
    
    
    //float plotValue = plot(uvn.y, f);
    //float circleValue = circle(vec2(0.5), uvn, 0.3, 0.01);
      
    color = vec3(d);  
    //color = vec3(fract(d*10.0));
    color = vec3(step(0.3, d));  
    color = vec3(step(d, 0.4));   
    color = vec3(step(0.3, d) * step(d, 0.4));
    color = vec3(smoothstep(0.3, 0.4, d) * smoothstep(0.6, 0.5, d));
    
    // Output to screen
	outColor = vec4(color, 1.0);
}