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

float circleWithAngle(vec2 origin, vec2 uv, float radius, float transition, float minAngle, float maxAngle)
{
	float dist = distance(origin, uv);
	vec2 pos = origin - uv;
	float a = atan(pos.y, pos.x);
	return smoothstep(radius-transition, radius+transition, dist) * step(minAngle, a);
}

void main( )
{
// Spatial coordinates
	vec2 uv = gl_FragCoord.xy-iResolution.xy*0.5;
// Normalized pixel coordinates (from 0 to 1)
	vec2 uvn = gl_FragCoord.xy/iResolution.xx;
    float ar = iResolution.y/iResolution.x;
    
    vec3 color = vec3(1.0, 0.0, 0.0);
    
    vec2 pos = vec2(0.5) - uvn;
    
	float r = length(pos)*2.;
	float a = atan(pos.y, pos.x);
	
    float f = abs(cos(a*4. + iTime));
    f = smoothstep(-0.5,1., cos(a*10. + iTime))*0.2+0.7;
    float f2 = abs(cos(a*4. + iTime));
    
    f = smoothstep(f, f2, r);
    
    //float plotValue = plot(uvn.y, f);
    //float circleValue = circle(vec2(0.5), uvn, 0.3, 0.01);
      
    float outside = step(f, r);
    //vec3 color2 = vec3(step(f2, r));
    
    //color = vec3((1.0 - step(f, r)) * step(f2, r));
    //color = vec3(f);
    
    float eye = circle(vec2(0.45, 0.55), uvn, 0.02, 0.001);
    float eye2 = circle(vec2(0.55, 0.55), uvn, 0.02, 0.001);
    
    float mouth = circle(vec2(0.5, 0.45), uvn, 0.05, 0.001);
    
    color = mix(vec3(0.5, 0.8, 0.9), outside * vec3(0.9, 0.5, 0.9), step(0.3, r));
    
    color = eye * color * eye2 * mouth;
    
    // Output to screen
	outColor = vec4(color, 1.0);
}