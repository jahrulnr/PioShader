// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "fragmentVersionSimple.h"
#include "uniformPerFrameConstants.h"

varying vec4 color;
varying vec3 pos;
varying vec4 ccolor;
varying vec2 fogControl;
varying vec4 fogColor;

struct data {
  float hujan;
  float siang;
  float matahari;
};

// Detect Source : Zaifa Shader v4.0
// ----------------------------------------------------------------------------------
void _deteksi( inout data deteksi, vec4 ccr ){
  deteksi.hujan = ( 1.0 - clamp( 3.34 * ( fogControl.y - 0.7 ), 0.0, 1.0 ) ); 
  deteksi.siang = min( max(( ccr.b - 0.15 ) * 1.1764706, 0.0 ), 1.0 ); 
  deteksi.matahari = ( 1.0 - fogColor.b ) * clamp( ( fogColor.r - 0.15 ) * 1.25, 0.0, 1.0 ) * 5.0;
}
// ----------------------------------------------------------------------------------

void main()
{
	// --- PioDiamond
		data deteksi;
		_deteksi( deteksi, ccolor );

		vec3 fc = fogColor.rgb;
		float lp = length( pos );
		float sstep = smoothstep( 0.0, 1.0, lp );
		vec3 siang = mix( vec3( 0.0, 0.3, 1.0 ), vec3( 0.0, 0.5, 1.0 ), pow( sstep, 0.4 ));
		vec3 malam = vec3( 0.0, 0.05, 0.11 );
		vec3 langit = mix( mix( malam, siang, deteksi.siang ), fc, deteksi.hujan );

		langit *= (2.0 - pow(fc.b, 2.0));
		vec4 color = vec4( mix( langit, fc, pow( sstep, 0.6 ) ), 0.0 );
	// --------------

	gl_FragColor = clamp(color, 0.0, 1.0);
}