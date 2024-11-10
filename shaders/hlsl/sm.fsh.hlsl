// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

#include "ShaderConstants.fxh"
#include "util.fxh"

struct PS_Input
{
    float4 position : SV_Position;
    float2 uv : TEXCOORD_0_FB_MSAA;

    float3 pos : pos;
    float2 fogControl : FOG_CONTROL;
    float4 fogColor : FOG_COLOR;
    float4 vpos : vpos;
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
#include "inc/.lensflare.fxh"
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE) || (VERSION < 0xa000 /*D3D_FEATURE_LEVEL_10_0*/) 
	float4 diffuse = TEXTURE_0.Sample(TextureSampler0, frac( PSInput.uv * 7.0 ));
#else
	float4 diffuse = texture2D_AA(TEXTURE_0, TextureSampler0, frac( PSInput.uv * 7.0 ));
#endif

// --- PioShader v5

    data deteksi;
    _deteksi( PSInput, deteksi, CURRENT_COLOR - 0.05 );
    float3 pos = PSInput.pos.xyz;
    float lp = max(0.5 -length( pos ), 0.0 );
    lp = pow( lp, 1.5 );

    float3 scolor = float3( 1.5, 1.0, -1.0 );

    // Source Code : Zaifa Shader v4 modif by PioDiamond
    // ----------------------------------------------------------------------------------
    float lingkar = smoothstep( 1.0, 0.0, pow( length( pos * 60.0 ), 5.0 ));
    float sm = max(0.0, lingkar);
    // ----------------------------------------------------------------------------------

    float3 matahari; 
    matahari.rgb = max( lp * lerp( float3( 1.0, 1.0, 1.0 ), scolor, deteksi.matahari ), float3( 0.0, 0.0, 0.0 ) );
    //diffuse.rgb = lerp( matahari, diffuse.rgb, ceil( 0.015 -length( pos ) ) );

    // Lensflare
    float2 u = -PSInput.vpos.xz * .08;
    float3 c = float3( 1.4, 1.2, 1. ) * lensflare( pos.xz * 7.5, u );
    c = cc( c, 0.1, 0.1 );
    matahari = ( matahari + pow( c, float3( 1.2, 1.2, 1.2  ))) * max( PSInput.fogColor.b *  1.2, 0.4 );
    diffuse = clamp( float4( lerp( matahari, diffuse.rgb, sm ), diffuse.a ) - 0.01, 0.0, 1.0 );

#ifdef IGNORE_CURRENTCOLOR
    PSOutput.color = diffuse;
#else
    PSOutput.color = CURRENT_COLOR * diffuse;
#endif

#ifdef WINDOWSMR_MAGICALPHA
    // Set the magic MR value alpha value so that this content pops over layers
    PSOutput.color.a = 133.0f / 255.0f;
#endif
}
