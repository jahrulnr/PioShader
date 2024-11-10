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
	float3 vpos : vpos;
	float proses : proses;
};

ROOT_SIGNATURE
#include "inc/settings.fxh"
void main(in VS_Input VSInput, out PS_Input PSInput)
{
    PSInput.proses = 1.0;
    PSInput.uv = VSInput.uv;
#ifdef INSTANCEDSTEREO
	int i = VSInput.instanceID;
	PSInput.position = mul(WORLDVIEWPROJ_STEREO[i], float4(VSInput.position, 1));
#else

#if CLOUDS
    float4 p = float4(VSInput.position, 1.0); p.y += 0.55;
    if( p.y == 1.05 ){
      PSInput.proses = 0.0;
      p.w = 0.0;
    }
    PSInput.position = mul(WORLDVIEWPROJ, p);
#else
    PSInput.position = mul(mul(WORLDVIEWPROJ, CUBE_MAP_ROTATION), float4(VSInput.position, 1.0));
#endif

#endif
#ifdef GEOMETRY_INSTANCEDSTEREO
	PSInput.instanceID = VSInput.instanceID;
#endif 
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	PSInput.renTarget_id = VSInput.instanceID;
#endif

    PSInput.pos = VSInput.position;
    PSInput.fogControl = FOG_CONTROL;
    PSInput.fogColor = FOG_COLOR;
    PSInput.vpos = mul(WORLDVIEWPROJ, float4(VSInput.position, 1.0)).xyz;

}