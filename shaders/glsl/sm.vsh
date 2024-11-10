// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond
//

#include "vertexVersionCentroidUV.h"

#include "uniformWorldConstants.h"
#include "inc/.hlsl2glsl.h"

attribute POS4 POSITION;
attribute vec2 TEXCOORD_0;
uniform vec2 FOG_CONTROL;
uniform vec4 FOG_COLOR;
uniform mat4 CUBE_MAP_ROTATION;

varying vec3 pos;
varying vec2 fogControl;
varying vec4 fogColor;
varying vec4 vpos;

void main()
{
    float2 size = float2( 5.0, 1.0 );
    float4 pmod = POSITION * float4( size, size );
    gl_Position = WORLDVIEWPROJ * (  pmod ) ;

    uv = TEXCOORD_0;
    pos = POSITION.xyz;
    vpos = mul( POSITION, WORLDVIEWPROJ );
    fogColor = FOG_COLOR;
    fogControl = FOG_CONTROL;
}