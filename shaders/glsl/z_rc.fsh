// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#define varying in
#define texture2D texture
out vec4 FragColor;
#define gl_FragColor FragColor

#ifndef BYPASS_PIXEL_SHADER
		varying vec2 uv0;
		varying vec2 uv1;
#endif

varying vec4 color;

#ifdef FOG
varying vec4 fogColor;
#endif

#ifdef MCPE_PLATFORM_NX
#extension GL_ARB_enhanced_layouts : enable
#define UNIFORM 
#else
#define UNIFORM uniform 
#endif

#if __VERSION__ >= 420
#define LAYOUT_BINDING(x) layout(binding = x)
#else
#define LAYOUT_BINDING(x) 
#endif

UNIFORM vec4 CURRENT_COLOR;
UNIFORM vec4 DARKEN;
UNIFORM vec3 TEXTURE_DIMENSIONS;
UNIFORM float HUD_OPACITY;
UNIFORM MAT4 UV_TRANSFORM;

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;
LAYOUT_BINDING(2) uniform sampler2D TEXTURE_2;

vec3 Uncharted2Tonemap(vec3 x)
{
	const float A = 0.28;
	const float B = 0.29;
	const float C = 0.10;
	const float D = 0.20;
	const float E = 0.025;
	const float F = 0.35;
	
	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

void setColor( inout vec3 c ){
//--- Tonemap
	const float W = 15.2;
	const float Contrast = 0.18;
	const float Exposure = 4.0;

	c *= Exposure*4.7;
	vec3 color = Uncharted2Tonemap(c) / Uncharted2Tonemap(vec3(W));
	
	c = pow(color, vec3( 1.0/Contrast ));
//--- End Tonemap

//--- Saturation
    const float adjustment = 1.4;
    vec3 gray = vec3(dot(c, vec3(0.2125, 0.7154, 0.0721)));
    c = mix(gray, c, adjustment);
//--- End Saturation
}

void main()
{
#ifdef BYPASS_PIXEL_SHADER
	gl_FragColor = vec4(0, 0, 0, 0);
	return;
#else 

vec4 diffuse = texture2D(TEXTURE_0, uv0);
	
#ifdef SEASONS_FAR
	diffuse.a = 1.0;
#endif

#ifdef ALPHA_TEST
	#ifdef ALPHA_TO_COVERAGE
	#define ALPHA_THRESHOLD 0.05
	#else
	#define ALPHA_THRESHOLD 0.5
	#endif
	if(diffuse.a < ALPHA_THRESHOLD)
		discard;
#endif

#if defined(BLEND)
	diffuse.a *= color.a;
#endif

#ifndef SEASONS
	#if !defined(ALPHA_TEST) && !defined(BLEND)
		diffuse.a = color.a;
	#endif
	
	diffuse.rgb *= color.rgb;
#else
	vec2 uv = color.xy;
	diffuse.rgb *= mix(vec3(1.0,1.0,1.0), texture2D( TEXTURE_2, uv).rgb*2.0, color.b);
	diffuse.rgb *= color.aaa;
	diffuse.a = 1.0;
#endif

//--- PioShader Super Lite Version
if( (color.b * 2.0 > color.r + color.g) == false ) setColor( diffuse.rgb );
//---

#if !defined(ALWAYS_LIT)
	diffuse *= texture2D( TEXTURE_1, uv1 );
#endif

#ifdef FOG
	diffuse.rgb = mix( diffuse.rgb, fogColor.rgb, sqrt(fogColor.a/2.0) );
#endif

	gl_FragColor = clamp(diffuse, 0.0, 1.0);
	
#endif // BYPASS_PIXEL_SHADER
}
