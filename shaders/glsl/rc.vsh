// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond
//

#include "vertexVersionCentroid.h"
#if __VERSION__ >= 300
	#ifndef BYPASS_PIXEL_SHADER
		_centroid out highp vec2 uv0;
		_centroid out highp vec2 uv1;
	#endif
#else
	#ifndef BYPASS_PIXEL_SHADER
		varying highp vec2 uv0;
		varying highp vec2 uv1;
	#endif
#endif

#ifndef BYPASS_PIXEL_SHADER
	varying vec4 color;
  varying vec4 fogColor;
	varying vec2 fogControl;
	varying highp vec3 pos;
	varying vec4 worldPos;
	varying vec4 vpos;
	varying float stop;
#endif

#include "inc/.hlsl2glsl.h"
#include "uniformWorldConstants.h"
#include "uniformPerFrameConstants.h"
#include "uniformShaderConstants.h"
#include "uniformRenderChunkConstants.h"
#include "inc/settings.h"

attribute highp vec4 POSITION;
attribute highp vec4 COLOR;
attribute highp vec2 TEXCOORD_0;
attribute highp vec2 TEXCOORD_1;

void main()
{
//#ifndef BYPASS_PIXEL_SHADER
    uv0 = TEXCOORD_0;
    uv1 = TEXCOORD_1;
    color = COLOR;
    stop = (length(worldPos.xyz) / RENDER_DISTANCE) * 1.11;
//#endif

#ifdef AS_ENTITY_RENDERER
		vec4 wpos = worldPos = WORLDVIEWPROJ * POSITION;
#else
    worldPos.xyz = (POSITION.xyz * CHUNK_ORIGIN_AND_SCALE.w) + CHUNK_ORIGIN_AND_SCALE.xyz;
    worldPos.w = stop >= 1.0 ? 0.0 : 1.0;
    vec4 wpos = PROJ * ( WORLDVIEW * worldPos );
#endif
    gl_Position = wpos;
    if( stop >= 1.0 ) return;

	fogControl = FOG_CONTROL;
	pos = POSITION.xyz;
	vpos = WORLDVIEWPROJ * worldPos;

// --- PioDiamond

	#ifdef ALPHA_TEST
		if ( color.g > color.b ) {
			#if LEAVES_WAVE || GRASS_WAVE
			float wavePos = length( pos - 8.0 );
			float wave = sin( TIME * 2.0 + wavePos ) * sin( TIME * 0.25 ) * 0.03 * uv1.y;
			#endif

			#if LEAVES_WAVE
			if( color.a == 0.0 ) gl_Position.x += wave;
			#endif

			#if GRASS_WAVE
			if( color.a > 0.0 ) gl_Position.x += wave;
			#endif
		}
	#endif

// ---------------

#if defined(FOG) || defined(BLEND)
	#ifdef FANCY
		float cameraDepth = length(-worldPos.xyz);
	#else
		float cameraDepth = wpos.z;
	#endif
#endif

#ifdef FOG
	float len = cameraDepth / RENDER_DISTANCE;
	#ifdef ALLOW_FADE
		len += RENDER_CHUNK_FOG_ALPHA;
	#endif

    fogColor.rgb = FOG_COLOR.rgb;
	fogColor.a = clamp((len - FOG_CONTROL.x) / (FOG_CONTROL.y - FOG_CONTROL.x), 0.0, 1.0);
#else
  fogColor = FOG_COLOR;
#endif

#ifdef BLEND
	if(color.a < 0.95) {
		#ifdef FANCY  /////enhance water
			float cameraDist = cameraDepth / FAR_CHUNKS_DISTANCE;
			color = COLOR;
		#else
			vec4 surfColor = vec4(color.rgb, 1.0);
			color = surfColor;

			float camDist = length(-worldPos.xyz);
			float cameraDist = camDist / FAR_CHUNKS_DISTANCE;
		#endif //FANCY

		color.a = mix(color.a, 1.0, clamp(pow(cameraDist * 1.1, 2.0), 0.0, 1.0));
	}
#endif
}
