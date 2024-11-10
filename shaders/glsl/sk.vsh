// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond
//

#include "vertexVersionSimple.h"

#include "uniformWorldConstants.h"
#include "uniformPerFrameConstants.h"
#include "uniformShaderConstants.h"

attribute highp vec4 POSITION;
attribute vec4 COLOR; 

varying vec4 color;
varying vec3 pos;
varying vec4 ccolor;
varying vec2 fogControl;
varying vec4 fogColor;

const float fogNear = 0.3;

void main()
{
	vec4 pmod = POSITION;
	pmod.y -= length( pmod.xyz ) * 0.15;
    gl_Position = WORLDVIEWPROJ * pmod;

    color = mix( CURRENT_COLOR, FOG_COLOR, COLOR.r );
    pos = POSITION.xyz;
    ccolor = CURRENT_COLOR;
    fogControl = FOG_CONTROL;
    fogColor = FOG_COLOR;
}