// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond
//

#include "vertexVersionCentroidUV.h"

#include "uniformWorldConstants.h"
#include "uniformEntityConstants.h"
#include "uniformPerFrameConstants.h"
#ifdef USE_SKINNING
#include "uniformAnimationConstants.h"
#endif

#line 13

attribute highp vec4 POSITION;
attribute vec2 TEXCOORD_0;
attribute vec4 NORMAL;
#if defined(USE_SKINNING)
#ifdef MCPE_PLATFORM_NX
attribute uint BONEID_0;
#else
attribute float BONEID_0;
#endif
#endif

#ifdef COLOR_BASED
	attribute vec4 COLOR;
	varying vec4 vertColor;
#endif

varying vec4 light;
varying vec4 fogColor;

#ifdef USE_OVERLAY
	// When drawing horses on specific android devices, overlay color ends up being garbage data.
	// Changing overlay color to high precision appears to fix the issue on devices tested
	varying highp vec4 overlayColor;
#else
	varying highp vec3 pos;
#endif

#ifdef TINTED_ALPHA_TEST
	varying float alphaTestMultiplier;
#endif

#ifdef GLINT
	varying vec2 layer1UV;
	varying vec2 layer2UV;
	varying vec4 tileLightColor;
	varying vec4 glintColor;
#endif

const float AMBIENT = 0.45;

const float XFAC = -0.1;
const float ZFAC = 0.1;

float lightIntensity(vec4 position, vec4 normal) {
#ifdef FANCY
	vec3 N = normalize( WORLD * normal ).xyz;

	N.y *= TILE_LIGHT_COLOR.w; //TILE_LIGHT_COLOR.w contains the direction of the light

	//take care of double sided polygons on materials without culling
	#ifdef FLIP_BACKFACES
		vec3 viewDir = normalize((WORLD * position).xyz);
		if( dot(N, viewDir) > 0.0 )
			N *= -1.0;
	#endif

		float yLight = (1.0+N.y) * 0.5;
		return yLight * (1.0-AMBIENT) + N.x*N.x * XFAC + N.z*N.z * ZFAC + AMBIENT;
#else
	return 1.0;
#endif
}

#ifdef GLINT
vec2 calculateLayerUV(float offset, float rotation) {
	vec2 uv = TEXCOORD_0;
	uv -= 0.5;
	float rsin = sin(rotation);
	float rcos = cos(rotation);
	uv = mat2(rcos, -rsin, rsin, rcos) * uv;
	uv.x += offset;
	uv += 0.5;

	return uv * GLINT_UV_SCALE;
}
#endif

void main()
{
	POS4 entitySpacePosition;
	POS4 entitySpaceNormal;

#ifdef USE_SKINNING
	#if defined(LARGE_VERTEX_SHADER_UNIFORMS)
		entitySpacePosition = BONES[int(BONEID_0)] * POSITION;
		entitySpaceNormal = BONES[int(BONEID_0)] * NORMAL;
	#else
		entitySpacePosition = BONE * POSITION;
		entitySpaceNormal = BONE * NORMAL;
	#endif
#else
	entitySpacePosition = POSITION * vec4(1, 1, 1, 1);
	entitySpaceNormal = NORMAL * vec4(1, 1, 1, 0);
#endif
	POS4 epos = WORLDVIEWPROJ * entitySpacePosition;
	gl_Position = epos;

	float L = lightIntensity(entitySpacePosition, entitySpaceNormal);

#ifdef USE_OVERLAY
	L += OVERLAY_COLOR.a * 0.35;
#else
	pos = POSITION.xyz;
#endif

#ifdef TINTED_ALPHA_TEST
	alphaTestMultiplier = OVERLAY_COLOR.a;
#endif

	light = vec4(vec3(L) * TILE_LIGHT_COLOR.xyz, 1.0);

#ifdef COLOR_BASED
	vertColor = COLOR;
#endif
	
#ifdef USE_OVERLAY
	overlayColor = OVERLAY_COLOR;
#endif

#ifndef NO_TEXTURE
	uv = TEXCOORD_0;
#endif

#ifdef USE_UV_ANIM
	uv.xy = UV_ANIM.xy + (uv.xy * UV_ANIM.zw);
#endif

#ifdef GLINT
	glintColor = GLINT_COLOR;
	layer1UV = calculateLayerUV(UV_OFFSET.x, UV_ROTATION.x);
	layer2UV = calculateLayerUV(UV_OFFSET.y, UV_ROTATION.y);
	tileLightColor = TILE_LIGHT_COLOR;
#endif

	//fog
	fogColor.rgb = FOG_COLOR.rgb;
	fogColor.a = clamp(((epos.z / RENDER_DISTANCE) - FOG_CONTROL.x) / (FOG_CONTROL.y - FOG_CONTROL.x), 0.0, 1.0);
}