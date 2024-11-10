// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

//#ifdef CLOUDS
#include "inc/.noise.h"
//#endif

struct data {
  float hujan;
  float siang;
  float matahari;
};

// Detect Source : Zaifa Shader v4.0
//----------------------------------------------------------------------------------
void _deteksi( inout data deteksi, float4 ccr ){
  deteksi.hujan = ( 1.0 - clamp( 3.34 * ( fogControl.y - 0.7 ), 0.0, 1.0 ) ); 
  deteksi.siang = min( max(( ccr.b - 0.15 ) * 1.1764706, 0.0 ), 1.0 ); 
  deteksi.matahari = ( 1.0 - fogColor.b ) * clamp( ( fogColor.r - 0.15 ) * 1.25, 0.0, 1.0 ) * 5.0;
}
//----------------------------------------------------------------------------------