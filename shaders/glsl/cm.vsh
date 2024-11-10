// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond
//

#include "vertexVersionCentroidUV.h"
#include "inc/settings.h"
#include "uniformWorldConstants.h"

attribute highp vec4 POSITION;
attribute vec2 TEXCOORD_0;
uniform vec4 FOG_COLOR;
uniform vec2 FOG_CONTROL;
uniform mat4 CUBE_MAP_ROTATION;

varying highp vec3 pos;
varying vec2 fogControl;
varying vec4 fogColor;
varying vec3 vpos;
varying float proses;
void main()
{

    proses = 1.0;

#if CLOUDS
    highp vec4 p = POSITION; p.y += 0.55;
    if( POSITION.y == 0.5 ){
      proses = 0.0;
      p.w = 0.0;
    }
    gl_Position = WORLDVIEWPROJ * (p);
#else
    gl_Position = WORLDVIEWPROJ * CUBE_MAP_ROTATION * POSITION;
#endif
    pos = POSITION.xyz;
    fogControl = FOG_CONTROL;
    fogColor = FOG_COLOR;
    uv = TEXCOORD_0;
    vpos = (WORLDVIEWPROJ * POSITION).xyz;
}