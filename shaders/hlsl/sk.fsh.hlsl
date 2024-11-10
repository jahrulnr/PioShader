// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

#include "ShaderConstants.fxh"

struct PS_Input
{
    float4 position : SV_Position;
    float4 color : COLOR;

	float3 pos : pos;
	float4 ccolor : CURRENT_COLOR;
	float2 fogControl : FOG_CONTROL;
	float4 fogColor : FOG_COLOR;

};

struct PS_Output
{
    float4 color : SV_Target;
};

struct data {
  float hujan : hujan;
  float siang : siang;
  float matahari : matahari;
};

ROOT_SIGNATURE
#define fragment
#include "inc/.sky.fxh"
void main(in PS_Input PSInput, out PS_Output PSOutput)
{

// --- PioDiamond
	data deteksi;
	_deteksi( PSInput, deteksi, PSInput.ccolor );

	float3 fc = PSInput.fogColor.rgb;
	float lp = length( PSInput.pos );
	float sstep = smoothstep( 0.0, 1.0, lp );
	float3 siang = lerp( float3( 0.0, 0.3, 1.0 ), float3( 0.0, 0.5, 1.0 ), pow( sstep, 0.4 ));
	float3 malam = float3( 0.0, 0.05, 0.11 );
	float3 langit = lerp( lerp( malam, siang, deteksi.siang ), fc, deteksi.hujan );

	langit *= (2.0 - pow(fc.b, 2.0));
	float4 color = float4( lerp( langit, fc, pow( sstep, 0.6 )), 0.0 );
// --------------

    PSOutput.color = color;
}