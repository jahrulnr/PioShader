// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

#include "ShaderConstants.fxh"
#include "inc/.glsl2hlsl.fxh"

struct VS_Input {
	float3 position : POSITION;
	float4 color : COLOR;
	float2 uv0 : TEXCOORD_0;
	float2 uv1 : TEXCOORD_1;
#ifdef INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
};


struct PS_Input {
	float4 position : SV_Position;

#ifndef BYPASS_PIXEL_SHADER
	lpfloat4 color : COLOR;
	snorm float2 uv0 : TEXCOORD_0_FB_MSAA;
	snorm float2 uv1 : TEXCOORD_1_FB_MSAA;
#endif

#ifdef PioShader_v5
	float4 fogColor : FOG_COLOR;
	float2 fogControl : FOG_CONTROL;
	float3 pos : POSITION;
	vec3 worldPos : worldPos;
#endif

#ifdef GEOMETRY_INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	uint renTarget_id : SV_RenderTargetArrayIndex;
#endif
};


// static const float rA = 1.0;
// static const float rB = 1.0;
// static const float3 UNIT_Y = float3(0, 1, 0);
// static const float DIST_DESATURATION = 56.0 / 255.0; //WARNING this value is also hardcoded in the water color, don'tchange


ROOT_SIGNATURE
// --- PioShader v5
#include "inc/settings.fxh"
// ----------------
void main(in VS_Input VSInput, out PS_Input PSInput)
{
#ifndef BYPASS_PIXEL_SHADER
	PSInput.uv0 = VSInput.uv0;
	PSInput.uv1 = VSInput.uv1;
	PSInput.color = VSInput.color;
	PSInput.pos = VSInput.position;
#endif

#ifdef AS_ENTITY_RENDERER
	#ifdef INSTANCEDSTEREO
		int i = VSInput.instanceID;
		PSInput.position = mul(WORLDVIEWPROJ_STEREO[i], float4(VSInput.position, 1));
	#else
		PSInput.position = mul(WORLDVIEWPROJ, float4(VSInput.position, 1));
	#endif
		float3 worldPos = PSInput.position;
#else
		float3 worldPos = (VSInput.position.xyz * CHUNK_ORIGIN_AND_SCALE.w) + CHUNK_ORIGIN_AND_SCALE.xyz;
	
		// Transform to view space before projection instead of all at once to avoid floating point errors
		// Not required for entities because they are already offset by camera translation before rendering
		// World position here is calculated above and can get huge
	#ifdef INSTANCEDSTEREO
		int i = VSInput.instanceID;
	
		PSInput.position = mul(WORLDVIEW_STEREO[i], float4(worldPos, 1 ));
		PSInput.position = mul(PROJ_STEREO[i], PSInput.position);
	
	#else
		int dstop = 1;
		if(length(worldPos) / RENDER_DISTANCE * 1.11 > 1.0) dstop = 0;
		PSInput.position = mul(WORLDVIEW, float4( worldPos, dstop ));
		PSInput.position = mul(PROJ, PSInput.position);
	#endif

#endif

PSInput.fogColor = FOG_COLOR;
PSInput.fogControl = FOG_CONTROL;
PSInput.pos = VSInput.position;
PSInput.worldPos = worldPos;

#ifdef ALPHA_TEST
	if ( PSInput.color.g > PSInput.color.b ) {
		#if LEAVES_WAVE || GRASS_WAVE
		float wavePos = length( PSInput.pos - 8.0 );
		float wave = sin( TIME * 2.0 + wavePos ) * sin( TIME * 0.25 ) * 0.03 * PSInput.uv1.y;
		#endif

		#if LEAVES_WAVE
		if( PSInput.color.a == 0.0 ) PSInput.position.x += wave;
		#endif

		#if GRASS_WAVE
		if( PSInput.color.a > 0.0 ) PSInput.position.x += wave;
		#endif
	}
#endif

#ifdef GEOMETRY_INSTANCEDSTEREO
		PSInput.instanceID = VSInput.instanceID;
#endif 
#ifdef VERTEXSHADER_INSTANCEDSTEREO
		PSInput.renTarget_id = VSInput.instanceID;
#endif
///// find distance from the camera

#if defined(FOG) || defined(BLEND)
	#ifdef FANCY
		float3 relPos = -worldPos;
		float cameraDepth = length(relPos);
	#else
		float cameraDepth = PSInput.position.z;
	#endif
#endif

	///// apply fog

#ifdef FOG
	float len = cameraDepth / RENDER_DISTANCE;
#ifdef ALLOW_FADE
	len += RENDER_CHUNK_FOG_ALPHA.r;
#endif
	PSInput.fogColor.a = clamp((len - FOG_CONTROL.x) / (FOG_CONTROL.y - FOG_CONTROL.x), 0.0, 1.0);
#endif

///// blended layer (mostly water) magic
#ifdef BLEND
	//Mega hack: only things that become opaque are allowed to have vertex-driven transparency in the Blended layer...
	//to fix this we'd need to find more space for a flag in the vertex format. color.a is the only unused part
	bool shouldBecomeOpaqueInTheDistance = VSInput.color.a < 0.95;
	if(shouldBecomeOpaqueInTheDistance) {
		#ifdef FANCY  /////enhance water
			float cameraDist = cameraDepth / FAR_CHUNKS_DISTANCE;
		#else
			float3 relPos = -worldPos.xyz;
			float camDist = length(relPos);
			float cameraDist = camDist / FAR_CHUNKS_DISTANCE;
		#endif //FANCY
		
		float alphaFadeOut = clamp(pow(cameraDist * 1.1, 2.0), 0.0, 1.0);
		PSInput.color.a = lerp(VSInput.color.a, 1.0, alphaFadeOut);
	}
#endif

}