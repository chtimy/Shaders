#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

out vec4 outColor;

#define TWO_PI 6.28318530718
#define PI TWO_PI * 0.5

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

float polarShapes(vec2 origin, vec2 uv, float radius, float transition, float fAngle)
{
	vec2 pos = origin - uv;
	float dist = length(pos);
	radius = fAngle * radius;
	return smoothstep(radius-transition, radius+transition, dist);
}

float drawEye(vec2 origin, vec2 st)
{
	vec2 pos = origin - st;
	float a = atan(pos.y, pos.x);
	float fAngle = max(cos(a*8.), 0.3);
	return polarShapes(origin, st, 0.02, 0.001, fAngle);
}

float circleWithAngle(vec2 origin, vec2 uv, float radius, float transition, float minAngle, float maxAngle)
{
	vec2 pos = origin - uv;
	float dist = length(pos);
	float a = (atan(pos.y, pos.x) / PI) * 2.0;
	
	float circle = smoothstep(radius-transition, radius+transition, dist);
	float cropCircle = (1.0 - circle) * step(dist, step(minAngle, a));
	return 1.0 - cropCircle;
}

vec2 tile(vec2 st, float width, float height)
{
	return fract(vec2(st.x * width, st.y * height));
}

vec3 flower(vec2 st)
{
	vec2 pos = vec2(0.5) - st;
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
    
    vec3 eye = vec3(1.0, 0.0, 0.0) * drawEye(vec2(0.45, 0.55), st);
    float eye2 = circle(vec2(0.55, 0.55), st, 0.02, 0.001);
    
    float mouth = circleWithAngle(vec2(0.5, 0.45), st, 0.05, 0.001, 0.0, 0.5);
    
    vec3 color = mix(vec3(0.5, 0.8, 0.9), outside * vec3(0.9, 0.5, 0.9), step(0.3, r));
    
    return eye * color * eye2 * mouth;
}

void main( )
{
// Spatial coordinates
	vec2 uv = gl_FragCoord.xy-iResolution.xy*0.5;
// Normalized pixel coordinates (from 0 to 1)
	vec2 uvn = gl_FragCoord.xy/iResolution.xx;
    float ar = iResolution.y/iResolution.x;
    
    vec2 st = tile(uvn, 6.0, 6.0);
    
    vec3 pairColor = flower(st);
    vec3 impairColor = 1.0 - pairColor;
    
    vec2 uvScale = floor(uvn * 6.0);
    float pair = mod(uvScale.x + uvScale.y, 2);
    
    vec3 color = pair * pairColor + (1.0 - pair) * impairColor;
    
    //vec3 color = vec3(pair, 0.0, 0.0);
    
    // Output to screen
	outColor = vec4(color, 1.0);
}