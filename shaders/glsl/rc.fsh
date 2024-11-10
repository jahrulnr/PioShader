// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

float LightMin = 0.0; // Dont Remove me!!!

#include "fragmentVersionCentroid.h"

#if __VERSION__ >= 300
	#ifndef BYPASS_PIXEL_SHADER
		#if defined(TEXEL_AA) && defined(TEXEL_AA_FEATURE)
			_centroid in highp vec2 uv0;
			_centroid in highp vec2 uv1;
		#else
			_centroid in lowp vec2 uv0;
			_centroid in lowp vec2 uv1;
		#endif
	#endif
#else
	#ifndef BYPASS_PIXEL_SHADER
		varying highp vec2 uv0;
		varying highp vec2 uv1;
	#endif
#endif

varying vec4 color;
varying vec4 fogColor;
varying vec2 fogControl;
varying highp vec3 pos;
varying vec4 worldPos;
varying vec4 vpos;

#include "inc/.hlsl2glsl.h"
#include "uniformShaderConstants.h"
#include "uniformPerFrameConstants.h"
#include "util.h"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;

#ifdef SEASONS
LAYOUT_BINDING(2) uniform sampler2D TEXTURE_2;
#endif

// --- PioShader
	#define fragment
	#include "inc/settings.h"
	#include "inc/.render.h"
// -------------

void main()
{

#ifndef BYPASS_PIXEL_SHADER

	float oc;
  float4 df;
  float4 diffuse;
	bool Is_Water = is_water();
	data deteksi;
	_deteksi( deteksi );

if ( Is_Water ){

	df.a = diffuse.a = color.a;

#if USE_ALPHA_TEST
	#ifdef ALPHA_TO_COVERAGE
		#define ALPHA_THRESHOLD 0.05
	#else
		#define ALPHA_THRESHOLD 0.5
	#endif
	if(diffuse.a < ALPHA_THRESHOLD)
		{ discard; return; }
#endif

	oc = 1.0 - ( smoothstep( 0.0, 0.9, uv1.y ) );
	
	df.rgb = lerp( float3( 0.0, 0.5, 1.0 ), float3( 0.3 ) * uv1.x, oc );
	df.rgb = diffuse.rgb = lerp( df.rgb, fogColor.rgb, deteksi.hujan );

	#if WATER_WAVES
		  water_color( diffuse, deteksi );
		  df = diffuse;
	#endif

} else {

#if USE_TEXEL_AA
	diffuse = texture2D_AA(TEXTURE_0, uv0);
#else
	diffuse = texture2D(TEXTURE_0, uv0);
#endif

df = diffuse;

#ifdef SEASONS_FAR
	diffuse.a = 1.0;
#endif

#if USE_ALPHA_TEST
	#ifdef ALPHA_TO_COVERAGE
	#define ALPHA_THRESHOLD 0.05
	#else
	#define ALPHA_THRESHOLD 0.5
	#endif
	if(diffuse.a < ALPHA_THRESHOLD)
		{ discard; return; }

#endif

#if defined(BLEND)
	diffuse.a *= color.a;
#endif

#ifndef SEASONS
	#if !USE_ALPHA_TEST && !defined(BLEND)
		diffuse.a = color.a;
	#endif

//--- Shadow bug Fix from Bicubic Shader
	diffuse.rgb *= mix(normalize(color.rgb), color.rgb, max(0.5, sqrt(_distance( 10.0 ))));

//--- Under Block Light Fix
	if( worldPos.y > 0.0 && (fract( pos.y ) == 0.0 || fract( pos.y ) == 0.5)) diffuse.rgb *= lerp( 0.9, 0.67, ( 1.0 - uv1.x ) * deteksi.siang * ( 1.0 - deteksi.hujan ) );

#else
	vec2 uv = color.xy;
	diffuse.rgb *= mix( vec3(1.0,1.0,1.0), texture2D( TEXTURE_2, uv).rgb*2.0, color.b );
	diffuse.rgb *= color.aaa;
	diffuse.a = 1.0;
#endif

// --- PioShader

  setColor( diffuse.rgb );

	//siang
	float3 siang = diffuse.rgb;

	//sore
	float3 sore = min(lerp( float3( 0.0, 0.0, 0.0 ), float3( 0.4, 0.2, -0.05 ), length( diffuse.rgb ) ) + diffuse.rgb, 1.0);

	//malam
	float3 malam = lerp(float3( 0.4, 0.7, 1.0 ) * diffuse.rgb, diffuse.rgb, uv1.x) * 0.7;

	//hujan
	float3 hujan = saturation( diffuse.rgb, 0.7 );

	//set light
	sore = lerp( siang, sore, max( 0.5 - abs( deteksi.siang - 0.5 ),  0.0) * 2.0 * ( 1.0 - deteksi.hujan ) );
	diffuse.rgb = lerp( malam, sore, deteksi.siang );
	diffuse.rgb = lerp( diffuse.rgb, hujan, deteksi.hujan * uv1.y ) /* lerp( 1.0, 0.6, deteksi.siang * deteksi.hujan )*/;
} // Is_Water

if( !is_nether() ){
	#ifndef FOG_UNDERWATER
	  float3 sblock = _shadowblock( deteksi, diffuse.rgb );
	  #if BLOCK_SHADOW
	    if( Is_Water == false ) diffuse.rgb = sblock;
	  #endif
		#if GRASS_SHADOW
		  diffuse.rgb = lerp( diffuse.rgb, _grass( deteksi, diffuse.rgb ), sblock );
		#endif

		#if SUN_REFLECTION && !defined( ALPHA_TEST )
		   sun( deteksi, diffuse,  Is_Water );
		#endif

		#if CLOUDS_REFLECTION && !defined( ALPHA_TEST )
		if (( Is_Water || ( diffuse.a < 0.95 && color.a > 0.0 && frac( pos.y ) == 0.0 ))){
		   float skala = Is_Water ? sin(diffuse.g) : 0.4;
		   float3 awan = max( PioClouds(( worldPos.zx * skala * float2( -1.0, 1.0 ) ) * 0.018, deteksi, 2 ) * ( max( uv1.y - 0.1, 0.0 ) ) * max( deteksi.siang, 0.3 ), 0.0 );
		   if( Is_Water ) {
		   awan =  awan * ( 1.0 - (df.r * 3.0)) * sqrt(_distance(14.0));
		   diffuse.rgb = clamp(diffuse.rgb + float3(awan.r, awan.g * 0.5, 0.0), 0.0, 1.0 );
		   }
		   else {
		   diffuse.rgb = clamp(diffuse.rgb + awan, 0.0, 1.0 );
		   }
		}
		#endif

		if( Is_Water ){
		diffuse *= max(sqrt(_distance( 16.0 )), (df.r) );
		diffuse.rgb = lerp( diffuse.rgb, fogColor.rgb, sqrt( _distance( 1.5 ) ));
		}

		#if DIRLIGHT
			if ( frac( pos.x ) == 0.0 && !Is_Water )
				diffuse.rgb *= lerp( 0.9, 0.7, uv1.y * ( 1.0 - uv1.x ) * deteksi.siang * ( 1.0 - deteksi.hujan ) );
		#endif

		#if RAIN_SPLASH
			if( deteksi.hujan > 0.4 && worldPos.y <= 0.25 ) diffuse.rgb += rain() * deteksi.hujan * 1.4;
		#endif

	#else

	//dalam air
		diffuse.rgb *= float3( 0.4, 0.6, 1.0 ) * max(clamp( deteksi.siang, 0.25, 0.8 ), uv1.x);

		#if CAUSTIC
		if ( Is_Water == false )
			diffuse.rgb += caustic( deteksi );
		#endif
	#endif
} // !is_nether

	_lightset( deteksi, diffuse, length( df.rgb ) );
	_fog( diffuse.rgb );

// -------------

  gl_FragColor =  clamp(diffuse, 0.0, 1.0);

#else
  gl_FragColor = vec4( 0 );
#endif // BYPASS_PIXEL_SHADER
}
