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

vec3 hsb2rgb( in vec3 c )
{
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0,0.0,1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix( vec3(1.0), rgb, c.y);
}

vec3 hsb2rgbWithFilter(vec3 c, float angle, float rangeAngle)
{
	float isInsideRange = step(angle - rangeAngle, c.x) * (1.0-step(angle + rangeAngle, c.x));
	return hsb2rgb(vec3(c.xy, isInsideRange));
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
    
    float f = uvn.x;
    
    //float plotValue = plot(uvn.y, f);
    //float circleValue = circle(vec2(0.5), uvn, 0.3, 0.01);
    
    vec2 toCenter = vec2(0.5) - uvn;
    float angle = atan(toCenter.y, toCenter.x);
    float radius = length(toCenter) * 2.0;
    
    float circleBorder = step(radius, 1.0);
    
    vec3 color = circleBorder * hsb2rgbWithFilter(vec3(angle/TWO_PI+0.5, radius, 1.0), 0.5, 0.2) + (1.0 - circleBorder) * vec3(0.0);
    
    // Output to screen
	outColor = vec4(color, 1.0);
}