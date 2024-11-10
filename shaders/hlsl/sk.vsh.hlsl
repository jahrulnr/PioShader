// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

#include "ShaderConstants.fxh"

struct VS_Input
{
    float3 position : POSITION;
    float4 color : COLOR;
#ifdef INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
};


struct PS_Input
{
    float4 position : SV_Position;
    float4 color : COLOR;
#ifdef GEOMETRY_INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	uint renTarget_id : SV_RenderTargetArrayIndex;
#endif

	float3 pos : pos;
	float4 ccolor : CURRENT_COLOR;
	float2 fogControl : FOG_CONTROL;
	float4 fogColor : FOG_COLOR;

};

ROOT_SIGNATURE
void main(in VS_Input VSInput, out PS_Input PSInput)
{
#ifdef INSTANCEDSTEREO
	int i = VSInput.instanceID;
	PSInput.position = mul( WORLDVIEWPROJ_STEREO[i], float4( VSInput.position, 1 ) );
#else
	float4 pmod = float4(VSInput.position, 1.0);
	pmod.y -= length( pmod.xyz ) * 0.15;
	PSInput.position = mul(WORLDVIEWPROJ, pmod);
#endif
#ifdef GEOMETRY_INSTANCEDSTEREO
	PSInput.instanceID = VSInput.instanceID;
#endif 
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	PSInput.renTarget_id = VSInput.instanceID;
#endif

    PSInput.pos = VSInput.position;
    PSInput.ccolor = CURRENT_COLOR;
    PSInput.fogControl = FOG_CONTROL;
    PSInput.fogColor = FOG_COLOR;
    PSInput.color = lerp( CURRENT_COLOR, FOG_COLOR, VSInput.color.r );
}