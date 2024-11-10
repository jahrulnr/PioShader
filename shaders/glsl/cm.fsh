// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

#include "fragmentVersionCentroid.h"
#include "uniformShaderConstants.h"
#include "util.h"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
uniform highp float TIME;

varying highp vec3 pos;
varying vec2 fogControl;
varying vec4 fogColor;
varying vec2 uv;
varying vec3 vpos;
varying float proses;

#define fragment
#include "inc/.hlsl2glsl.h"
#include "inc/.sky.h"
#include "inc/settings.h"

#if CLOUDS
#include "inc/.clouds.h"
void main()
{
  if ( proses == 0.0 ){
		gl_FragColor = vec4( 0.0 );
		return;
	}

  data deteksi;
	_deteksi( deteksi, CURRENT_COLOR );
  vec3 p = ( pos );
  float lp = clamp( ( 0.5 -length( p.xz )) * 3.0, 0.0, 1.0 );
  lp = pow( lp, 0.7 );
  vec3 clouds_c = clouds( p.zx, deteksi ) * (max(fogColor.b, 0.7));
  vec3 diffuse = min( mix( fogColor.rgb * 1.6, clouds_c,  clouds_c.r ), 1.0 );
  //vec3 diffuse = clouds_c;

	gl_FragColor = clamp(vec4( diffuse, clouds_c.r * lp ), 0.0, 1.0 ) * CURRENT_COLOR;//vec4( diffuse, clamp(clouds_c.r, 0.0, 1.0) * lp ) * CURRENT_COLOR;
}

#else
void main(){
gl_FragColor = texture2D( TEXTURE_0, uv ) * CURRENT_COLOR;
}
#endif
