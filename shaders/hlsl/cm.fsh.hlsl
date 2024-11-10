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
    float3 vpos : vpos;
    float proses : proses;

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
#include "inc/.sky.fxh"
#include "inc/settings.fxh"

#if CLOUDS == 1
#include "inc/.clouds.fxh"
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
    if ( PSInput.proses == 0.0 ){
        PSOutput.color = float4( 0.0, 0.0, 0.0, 0.0 );
        return;
    }

    data deteksi;
#ifdef IGNORE_CURRENTCOLOR    
    _deteksi( PSInput, deteksi, float4( 0.0, 0.0, 0.0, 0.0 ));
#else
    _deteksi( PSInput, deteksi, CURRENT_COLOR );
#endif

    float3 p = PSInput.pos;
    float lp = clamp(( 0.5 -length( p.xz )) * 3.0, 0.0, 1.0 );
    lp = pow( lp, 0.7 );
    float3 clouds_c = clouds( PSInput, p.zx, deteksi ) * max(PSInput.fogColor.b, 0.7);
    float3 diffuse = min(lerp( PSInput.fogColor.rgb * 1.6, clouds_c,  clouds_c.r ), 1.0 );

#ifdef IGNORE_CURRENTCOLOR
    PSOutput.color = clamp(float4( diffuse, clouds_c.r * lp ), 0.0, 1.0 );
#else
    PSOutput.color = CURRENT_COLOR * clamp(float4( diffuse, clouds_c.r * lp ), 0.0, 1.0 );
#endif

#ifdef WINDOWSMR_MAGICALPHA
    // Set the magic MR value alpha value so that this content pops over layers
    PSOutput.color.a = 133.0f / 255.0f;
#endif
}

#else

void main(in PS_Input PSInput, out PS_Output PSOutput)
{
#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE) || (VERSION < 0xa000 /*D3D_FEATURE_LEVEL_10_0*/) 
    float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv);
#else
    float4 diffuse = texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv);
#endif

#ifdef ALPHA_TEST
    if( diffuse.a < 0.5 )
    {
        discard;
    }
#endif

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
#endif