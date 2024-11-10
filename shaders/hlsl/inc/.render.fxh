// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

#define torch_color float3( 1.4, 1.2, 1.0 )
#define torch_underwater float3( 0.0, 0.5, 1.0 )
#define sun_color float4( 1.0, 0.5, 0.0, 1.0 )

bool is_water(in PS_Input PSInput){
 bool water = false;
 #ifndef SEASONS
   if ( PSInput.color.b * 2.0 > PSInput.color.r + PSInput.color.g ){
     water = true;
    }
 #endif
 return water;
}

bool is_nether(in PS_Input PSInput){
  if( PSInput.fogColor.r * 2.0 > PSInput.fogColor.g + PSInput.fogColor.b && 
      PSInput.fogColor.r < 0.4 && PSInput.fogColor.r > 0.0 )
      return true; else return false;
}

#ifdef fragment
#if defined(WATER_WAVES) || defined(CLOUDS_REFLECTION)
#include "inc/.noise.fxh"
#endif
#include "inc/.color.fxh"
#if CLOUDS_REFLECTION
	#include "inc/.clouds.fxh"
#endif
#ifdef CAUSTIC
	#include "inc/.caustic.fxh"
#endif
#ifdef RAIN_SPLASH
	#include "inc/.rain.fxh"
#endif

void _deteksi(in PS_Input PSInput, inout data deteksi ){
	deteksi.siang = clamp(( TEXTURE_1.Sample(TextureSampler1, float2( 0.0, 1.0 )).r - 0.5 ) * 2.0, 0.0, 1.0 );
	deteksi.pagi = 2.0 * ( 0.5 - abs( 0.5 - clamp( ( deteksi.siang - 0.4 ) * 3.0, 0.0, 1.0 )));
#ifdef FOG
	deteksi.hujan = max( 1.0 - pow( PSInput.fogControl.y, 5.0 ), 0.0 );
#else
	deteksi.hujan = 0.0;
#endif
	deteksi.gelap = 1.0 -(min(max( PSInput.uv1.y - 0.83, 0.0 ) * 20.0, deteksi.siang ));
	deteksi.shadow = deteksi.gelap * deteksi.siang;
}

float _distance( in PS_Input PSInput, in float jarak ) {
  return clamp( length( PSInput.worldPos ) / RENDER_DISTANCE * jarak, 0.0, 1.0 );
}

#ifdef WATER_WAVES
void wNoise(  float2 uv, out float n, float timer ){
    const float skala = 3.7;
    float cepat = -TIME * timer;
    
    float2x2 m = float2x2( 1.6, 1.2, 1.2, 1.6 );
    float2 pos = skala * mul( float2( uv.x * 1.3 + cepat * 0.125, uv.y + cepat ), m );
    float n1 = noise( pos );
    n = max( n1 * 0.15, -0.1 );
}

void water_color( in PS_Input PSInput, inout float4 c, data deteksi ){
  float view = _distance( PSInput, 1.8 );

  if ( view > 0.0 ){
    float2 uv = PSInput.pos.xz;
    float n1;
    wNoise( -uv, n1, 0.15 );
    wNoise( uv*0.4 - sin(n1), n1, 0.2 );
    n1 = pow(n1, 3.0) * max(PSInput.uv1.y, 0.5) * 50.0;
    c = float4( c.rgb + n1 * float3( 1.0, 0.5, 0.0 ), clamp( c.a + n1 + view, c.a, 1.0 ));
  }
}
#endif

float3 _shadowblock( in PS_Input PSInput, in data deteksi, in float3 c ){
float3 shadow;
if( frac( PSInput.pos.y ) != 0.5 && PSInput.color.r != PSInput.color.b && PSInput.color.r != PSInput.color.g ){
   shadow = clamp( (PSInput.uv1.y - 0.5) * vec3( 2.0, 2.0, 2.0 ), 0.7, 1.0 );
}else{
   shadow = clamp( (PSInput.uv1.y - 0.5) * vec3( 2.0, 2.0, 2.0 ), 0.85, 1.0 );
}
  return c * mix( vec3( 1.0, 1.0, 1.0 ), shadow, deteksi.shadow * (1.0 -PSInput.uv1.x) );
}
//--------------
float3 _grass( in PS_Input PSInput, in data deteksi, in float3 diffuse ){
	#ifdef ALPHA_TEST
    if( PSInput.color.g > PSInput.color.b ){
    	diffuse.rgb *= 0.8;
		}
	#endif
  return diffuse;
}

void _lightset( in PS_Input PSInput, in data deteksi, inout float4 diffuse, float df ){
  #if !defined(ALWAYS_LIT) 
    float2 uvMod = is_water( PSInput ) ? float2( sqrt(PSInput.uv1.x), PSInput.uv1.y ) : PSInput.uv1;
    #if TORCH_COLOR
      float3 torch_;
      #ifdef FOG_UNDERWATER
      float4 LightSet = TEXTURE_1.Sample(TextureSampler1, uvMod );
      diffuse *= max(float4( LightSet.rg, sqrt( LightSet.b ), LightSet.a ), LightMin);
      #else
      float4 LightSet = TEXTURE_1.Sample(TextureSampler1, uvMod );
      float4 blue = float4( LightSet.rg, sqrt( LightSet.b ), LightSet.a );
      diffuse *= max(lerp( blue, LightSet, LightSet.r ), LightMin);
      #endif
    #else
      diffuse *= max(TEXTURE_1.Sample(TextureSampler1, uvMod ), LightMin);
    #endif
  #endif
}

void _fog( in PS_Input PSInput, inout float3 diffuse ) {
  float dist;

#ifndef FOG_UNDERWATER
   dist = pow( _distance( PSInput, 1.1 ), 11. )*0.7;
   if( dist > 0.0 ){
     float3 fog = lerp( PSInput.fogColor.rgb, 
      float3( 0.0, 0.5, 1.0 ), clamp(PSInput.worldPos.y / 50.0, 0.0, 1.0) * PSInput.fogColor.b );
	   diffuse = lerp( diffuse, fog, dist );
   }
#else
  dist = sqrt(_distance( PSInput, 4.0 ));
   if( dist > 0.0 ){
     float3 fog = float3(0.3, 0.6, 1.0) * PSInput.fogColor.b;
	   diffuse = lerp( diffuse, fog, dist );
   }
#endif
}

float wEffect(in PS_Input PSInput)
{
float3 np = normalize(PSInput.worldPos.xyz);
float sun = (.6-length(np.yz));
float f1pos = smoothstep(7.5 + abs(np.y)*2.0,0.0,abs(np.z)*.9);
float3 Pos = float3( f1pos, f1pos, f1pos );
float f1fr = max(0.0,sun);
float3 flatRange = float3( f1fr, f1fr, f1fr );
float specularFlat = max(dot(Pos, flatRange), 0.0);
return specularFlat * min( 1.0, 1.0 - PSInput.uv1.x );
}

void sun( in PS_Input PSInput, in data deteksi, inout float4 c, bool water ){ // 1
	float h = ( 0.0 );
	bool kena1 = ( frac( PSInput.pos.y ) == 0.0 || frac( PSInput.pos.y ) == 0.5 );
	bool kena2 = PSInput.color.r == PSInput.color.g && PSInput.color.r == PSInput.color.b;
	bool kena3 = PSInput.color.g > PSInput.color.b || PSInput.color.g > PSInput.color.r;
	float hujan = ( deteksi.hujan - 0.5 ) * 1.8;

	if ( deteksi.hujan > 0.5 ){ // 2
		if ( kena1 && PSInput.worldPos.y <= 0.25 ){ // 3
			h += ( 0.5 - abs( _distance( PSInput, 4.0 ) - 0.5 )) * PSInput.uv1.y * hujan * ( !kena2 ? 0.5 : 1.0 );
			c += h;
		} // 3
	} // 2

	else if ( ( water || ( kena1 && ( kena2 || kena3 ))) && PSInput.worldPos.y <= 0.25 ){ // 2
		h = wEffect( PSInput ) * deteksi.pagi * PSInput.uv1.y * min( 1.0 - hujan, 0.4 );

		if ( h > 0.0 ) { // 3
			if ( water ){ // 4
				c += lerp( float4( 0.0, 0.0, 0.0, 0.0 ), sun_color, h ) * length( c.rgb );
			} // 4
			else if( kena1 ){ // 4
				c += lerp( float4( 0.0, 0.0, 0.0, 0.0 ), sun_color , h );
			} // 4
			else { // 4
				float4 sc = sun_color - float4( 0.0, 0.2, 0.2, 0.0 );
				c += lerp( float4( 0.0, 0.0, 0.0, 0.0 ), sc , h ) * 0.65;
			} // 4
		} // 3
	} // 2
} // 1
//----------------------------------------------------------------------------------
#endif