// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

#include "ShaderConstants.fxh"

struct VS_Input
{
    float3 position : POSITION;
    float2 uv : TEXCOORD_0;
#ifdef INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
};


struct PS_Input
{
    float4 position : SV_Position;
    float2 uv : TEXCOORD_0;
#ifdef GEOMETRY_INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	uint renTarget_id : SV_RenderTargetArrayIndex;
#endif

	float3 pos : pos;
	float2 fogControl : FOG_CONTROL;
	float4 fogColor : FOG_COLOR;
	float4 vpos : vpos;

};

ROOT_SIGNATURE
void main(in VS_Input VSInput, out PS_Input PSInput)
{
    PSInput.uv = VSInput.uv;
#ifdef INSTANCEDSTEREO
	int i = VSInput.instanceID;
	PSInput.position = mul( WORLDVIEWPROJ_STEREO[i], float4( VSInput.position, 1 ) );
#else
    float2 size = float2( 5.0, 1.0 );
    float4 pmod = float4(VSInput.position, 1.0) * size.xyxy;
	PSInput.position = mul(WORLDVIEWPROJ, pmod);
#endif
#ifdef GEOMETRY_INSTANCEDSTEREO
	PSInput.instanceID = VSInput.instanceID;
#endif 
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	PSInput.renTarget_id = VSInput.instanceID;
#endif

    PSInput.pos = VSInput.position;
    PSInput.vpos = mul( float4(VSInput.position, 1.0), WORLDVIEWPROJ );
    PSInput.fogColor = FOG_COLOR;
    PSInput.fogControl = FOG_CONTROL;

}