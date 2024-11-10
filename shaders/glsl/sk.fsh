// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond
//

#include "fragmentVersionSimple.h"
#include "uniformPerFrameConstants.h"

varying vec4 color;
varying vec3 pos;
varying vec4 ccolor;
varying vec2 fogControl;
varying vec4 fogColor;

#define fragment
#include "inc/.hlsl2glsl.h"
#include "inc/.sky.h"

void main()
{
	// --- PioDiamond
		data deteksi;
		_deteksi( deteksi, ccolor );

		float3 fc = fogColor.rgb;
		float lp = length( pos );
		float sstep = smoothstep( 0.0, 1.0, lp );
		float3 siang = lerp( float3( 0.0, 0.3, 1.0 ), float3( 0.0, 0.5, 1.0 ), pow( sstep, 0.4 ));
		float3 malam = float3( 0.0, 0.05, 0.11 );
		float3 langit = lerp( lerp( malam, siang, deteksi.siang ), fc, deteksi.hujan );

		langit *= (2.0 - pow(fc.b, 2.0));
		float4 color = float4( lerp( langit, fc, pow( sstep, 0.6 ) ), 0.0 );
	// --------------

	gl_FragColor = clamp(color, 0.0, 1.0);
}