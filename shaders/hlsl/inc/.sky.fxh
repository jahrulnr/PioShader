// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

#ifndef in_noise
#define in_noise
#include "inc/.noise.fxh"
#endif

// Detect Source : Zaifa Shader v4.0
//----------------------------------------------------------------------------------
void _deteksi( in PS_Input PSInput, inout data deteksi, float4 ccr ){
  deteksi.hujan = ( 1.0 - clamp( 3.34 * ( PSInput.fogControl.y - 0.7 ), 0.0, 1.0 ) ); 
  deteksi.siang = min( max(( ccr.b - 0.15 ) * 1.1764706, 0.0 ), 1.0 ); 
  deteksi.matahari = ( 1.0 - PSInput.fogColor.b ) * clamp( ( PSInput.fogColor.r - 0.15 ) * 1.25, 0.0, 1.0 ) * 5.0;
}
//----------------------------------------------------------------------------------