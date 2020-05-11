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

float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
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


vec2 truchetPattern(in vec2 _st, in float _index){
    _index = fract(((_index-0.5)*2.0));
    if (_index > 0.75) {
        //_st = vec2(1.0) - _st;
        _st = _st;
    //} else if (_index > 0.5) {
      //  _st = vec2(1.0-_st.x,_st.y);
    } else if (_index > 0.25) {
        _st = 1.0-vec2(1.0-_st.x,_st.y);
    }
    return _st;
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

void main( )
{
// Spatial coordinates
	vec2 uv = gl_FragCoord.xy-iResolution.xy*0.5;
// Normalized pixel coordinates (from 0 to 1)
	vec2 uvn = gl_FragCoord.xy/iResolution.xx;
    float ar = iResolution.y/iResolution.x;
    
    vec2 st = uvn * 10.0;
    vec2 iPos = floor(st);
    vec2 fPos = fract(st);
    
    float noise = random(iPos);
    vec3 color = vec3(0.0);
    
    vec2 tile = truchetPattern(fPos, random( iPos ));
    
    color = vec3(smoothstep(tile.x-0.3,tile.x,tile.y)-smoothstep(tile.x,tile.x+0.3,tile.y));
    
    color = vec3((step(length(tile),0.6) - step(length(tile),0.4) ) + 
    (step(length(tile-vec2(1.)),0.6) - step(length(tile-vec2(1.)),0.4) ));
    
    //vec3 color = vec3(pair, 0.0, 0.0);
    
    // Output to screen
	outColor = vec4(color, 1.0);
}