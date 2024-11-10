// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond
//

#include "fragmentVersionCentroid.h"

#if __VERSION__ >= 300

#if defined(TEXEL_AA) && defined(TEXEL_AA_FEATURE)
_centroid in highp vec2 uv;
#else
_centroid in vec2 uv;
#endif

#else

varying vec2 uv;

#endif

varying vec3 pos;
varying vec2 fogControl;
varying vec4 fogColor;
varying vec4 vpos;

#include "uniformShaderConstants.h"
#include "util.h"
#define fragment
#include "inc/.hlsl2glsl.h"
#include "inc/.sky.h"
#include "inc/.lensflare.h"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;

void main()
{

#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE)
	vec4 diffuse = texture2D( TEXTURE_0, frac( uv * 7.0 ) );
#else
	vec4 diffuse = texture2D_AA(TEXTURE_0, frac( uv * 7.0 ) );
#endif

#ifdef ALPHA_TEST
	if(diffuse.a < 0.5)
		discard;
#endif

// --- PioShader

    data deteksi;
    _deteksi( deteksi, CURRENT_COLOR - 0.05 );
    float3 pos = pos.xyz;
    float lp = max(0.5 -length( pos ), 0.0 );
    lp = /*normalize( lp ) */ pow( lp, 1.5 );

    float3 scolor = float3( 1.5, 1.0, -1.0 );

    // Source Code : Zaifa Shader v4 ( sun_moon.fragment )
    // ----------------------------------------------------------------------------------
    float sm = 0.0;
    float lingkar = max( 1.0 - pow( length( pos * 60.0 ), 5.0), 0.0 );
    if( lingkar > 0.0 ) sm = (lingkar);
    // ----------------------------------------------------------------------------------

    float3 matahari; 
    matahari.rgb = max( lp * lerp( float3( 1.0, 1.0, 1.0 ), scolor, deteksi.matahari ), float3( 0.0, 0.0, 0.0 ) );
    //diffuse.rgb = lerp( matahari, diffuse.rgb, ceil( 0.015 -length( pos ) ) );

    // Lensflare
    float2 u = -vpos.xz * .08;
    float3 c = float3( 1.4, 1.2, 1. ) * lensflare( pos.xz * 7.5, u );
    c = cc( c, 0.1, 0.1 );
    matahari = ( matahari + pow( c, float3( 1.2, 1.2, 1.2  ))) * max( fogColor.b *  1.2, 0.4 );

	gl_FragColor = CURRENT_COLOR * clamp( float4( lerp( matahari, diffuse.rgb, sm ), diffuse.a ) - 0.01, 0.0, 1.0 ); 
}
