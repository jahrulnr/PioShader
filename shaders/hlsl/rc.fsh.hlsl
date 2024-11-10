// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

#include "ShaderConstants.fxh"
#include "util.fxh"
#include "inc/.glsl2hlsl.fxh"

float LightMin = 0.0; // Dont Remove me!!!
struct PS_Input
{
	float4 position : SV_Position;

#ifndef BYPASS_PIXEL_SHADER
	float4 color : COLOR;
	snorm float2 uv0 : TEXCOORD_0_FB_MSAA;
	snorm float2 uv1 : TEXCOORD_1_FB_MSAA;
#endif

#ifdef PioShader_v5
	float4 fogColor : FOG_COLOR;
	float2 fogControl : FOG_CONTROL;
	float3 pos : POSITION;
	float3 worldPos : worldPos;
#endif
};

struct PS_Output
{
	float4 color : SV_Target;
};

struct data {
	float gelap : gelap;
	float hujan : hujan;
	float siang : siang;
	float pagi : pagi;
	float shadow : shadow;
};

ROOT_SIGNATURE
// --- PioShader
	#define fragment
	#include "inc/settings.fxh"
	#include "inc/.render.fxh"
// -------------
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
#ifdef BYPASS_PIXEL_SHADER
    PSOutput.color = float4(0.0f, 0.0f, 0.0f, 0.0f);
    return;
#else

float oc;
float4 df;
float4 diffuse;
bool Is_Water = is_water( PSInput );
data deteksi;
_deteksi( PSInput, deteksi );

if ( Is_Water ){

	df.a = diffuse.a = PSInput.color.a;

#if USE_ALPHA_TEST
	#ifdef ALPHA_TO_COVERAGE
		#define ALPHA_THRESHOLD 0.05
	#else
		#define ALPHA_THRESHOLD 0.5
	#endif
	if(diffuse.a < ALPHA_THRESHOLD)
		{ discard; return; }
#endif

	oc = 1.0 - ( smoothstep( 0.0, 0.9, PSInput.uv1.y ) );
	
	df.rgb = lerp( float3( 0.0, 0.5, 1.0 ), float3( 0.3, 0.3, 0.3 ) * PSInput.uv1.x, oc );
	df.rgb = diffuse.rgb = lerp( df.rgb, PSInput.fogColor.rgb, deteksi.hujan );

	#if WATER_WAVES
		  water_color( PSInput, diffuse, deteksi );
		  df = diffuse;
	#endif

} else {

#if USE_TEXEL_AA
	df = diffuse = texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv0 );
#else
	df = diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv0);
#endif


#ifdef SEASONS_FAR
	diffuse.a = 1.0f;
#endif

#if USE_ALPHA_TEST
	#ifdef ALPHA_TO_COVERAGE
		#define ALPHA_THRESHOLD 0.05
	#else
		#define ALPHA_THRESHOLD 0.5
	#endif
	if(diffuse.a < ALPHA_THRESHOLD)
		discard;
#endif

#if defined(BLEND)
	diffuse.a *= PSInput.color.a;
#endif

#ifndef SEASONS
	#if !USE_ALPHA_TEST && !defined(BLEND)
		diffuse.a = PSInput.color.a;
	#endif	

//--- Shadow bug Fix from Bicubic Shader
	diffuse.rgb *= mix(normalize(PSInput.color.rgb), PSInput.color.rgb, max(0.5, sqrt(_distance( PSInput, 10.0 ))));

//--- Under Block Light Fix
	if( PSInput.worldPos.y > 0.0 && (fract( PSInput.pos.y ) == 0.0 || fract( PSInput.pos.y ) == 0.5)) 
		diffuse.rgb *= lerp( 0.9, 0.67, ( 1.0 - PSInput.uv1.x ) * deteksi.siang * ( 1.0 - deteksi.hujan ) );

#else
	float2 uv = PSInput.color.xy;
	diffuse.rgb *= lerp(1.0f, TEXTURE_2.Sample(TextureSampler2, uv).rgb*2.0f, PSInput.color.b);
	diffuse.rgb *= PSInput.color.aaa;
	diffuse.a = 1.0f;
#endif

// --- PioShader

  setColor( diffuse.rgb );

	//siang
	float3 siang = diffuse.rgb;

	//sore
	float3 sore = min(lerp( float3( 0.0, 0.0, 0.0 ), float3( 0.4, 0.2, -0.05 ), length( diffuse.rgb ) ) + diffuse.rgb, 1.0);

	//malam
	float3 malam = lerp(float3( 0.4, 0.7, 1.0 ) * diffuse.rgb, diffuse.rgb, PSInput.uv1.x) * 0.7;

	//hujan
	float3 hujan = vec3(0.5, 0.5, 0.5) * saturation( diffuse.rgb, 0.7 );

	//set light
	sore = lerp( siang, sore, max( 0.5 - abs( deteksi.siang - 0.5 ),  0.0) * 2.0 * ( 1.0 - deteksi.hujan ) );
	diffuse.rgb = lerp( malam, sore, deteksi.siang );
	diffuse.rgb = lerp( diffuse.rgb, hujan, deteksi.hujan * PSInput.uv1.y );

} // Is_Water

if( !is_nether( PSInput )){
	#ifndef FOG_UNDERWATER
	  float3 sblock = _shadowblock( PSInput, deteksi, diffuse.rgb );
	  #if BLOCK_SHADOW
	    if( Is_Water == false ) diffuse.rgb = sblock;
	  #endif
		#if GRASS_SHADOW
		  diffuse.rgb = lerp( diffuse.rgb, _grass( PSInput, deteksi, diffuse.rgb ), sblock );
		#endif

		#if SUN_REFLECTION && !defined( ALPHA_TEST )
		   sun( PSInput, deteksi, diffuse, Is_Water );
		#endif

		#if CLOUDS_REFLECTION && !defined( ALPHA_TEST )
		if (( Is_Water || ( diffuse.a < 0.95 && PSInput.color.a > 0.0 && frac( PSInput.pos.y ) == 0.0 ))){
		   float skala = Is_Water ? sin(diffuse.g) : 0.4;
		   float3 awan = max( PioClouds( PSInput, ( PSInput.worldPos.zx * skala * float2( -1.0, 1.0 )) * 0.018, deteksi, 2 ) 
		   	* ( max( PSInput.uv1.y - 0.1, 0.0 )) * max( deteksi.siang, 0.3 ), 0.0 );
		   if( Is_Water ) {
		   	awan = awan * ( 1.0 - (df.r * 3.0)) * sqrt(_distance( PSInput, 14.0 ));
			diffuse.rgb = clamp(diffuse.rgb + float3(awan.r, awan.g * 0.5, 0.0), 0.0, 1.0 );
		   }
		   else {
	   		diffuse.rgb = clamp(diffuse.rgb + awan, 0.0, 1.0 );
		   }
		}
		#endif

		if( Is_Water ){
		diffuse *= max(sqrt(_distance( PSInput, 16.0 )), (df.r) );
		diffuse.rgb = lerp( diffuse.rgb, PSInput.fogColor.rgb, sqrt( _distance( PSInput, 1.5 ) ));
		}

		#if DIRLIGHT
			if ( frac( PSInput.pos.x ) == 0.0 && !Is_Water )
				diffuse.rgb *= lerp( 0.9, 0.7, PSInput.uv1.y * ( 1.0 - PSInput.uv1.x ) 
					* deteksi.siang * ( 1.0 - deteksi.hujan ));
		#endif

		#if RAIN_SPLASH
			if( deteksi.hujan > 0.4 && PSInput.worldPos.y <= 0.25 ) diffuse.rgb += rain( PSInput ) 
				* deteksi.hujan * 1.4;
		#endif

	#else

	//dalam air
		diffuse.rgb *= float3( 0.4, 0.6, 1.0 ) * max(clamp( deteksi.siang, 0.25, 0.8 ), PSInput.uv1.x);

		#if CAUSTIC
		if ( Is_Water == false )
			diffuse.rgb += caustic( PSInput, deteksi );
		#endif
	#endif
} // !is_nether

	_lightset( PSInput, deteksi, diffuse, length( df.rgb ) );
	_fog( PSInput, diffuse.rgb );

	PSOutput.color = clamp( diffuse, 0.0, 1.0 );

#ifdef VR_MODE
	// On Rift, the transition from 0 brightness to the lowest 8 bit value is abrupt, so clamp to 
	// the lowest 8 bit value.
	PSOutput.color = max(PSOutput.color, 1 / 255.0f);
#endif

#endif // BYPASS_PIXEL_SHADER
}