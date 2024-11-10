// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond


#define rotate(x) float2x2(cos( x ), -sin( x ), sin( x ), cos( x ))

// "Clouds" Created by PioDiamond
// ----------------------------------------------------------------------------------
float3 PioClouds( in PS_Input PSInput, float2 p, data deteksi, int ulang ) {
  const float skala = 6.0;
  const float cepat = 0.02;
  float waktu = ( cepat * TIME );

  float3 pos = float3( p.x, length(p), p.y ); pos = pos / (pos.y + 0.3); pos.xz *= skala; pos.x *= 0.6;
  float clouds_;
  float d = 1.0;
  pos.xz += waktu * float2( 1.0, -1.0 );
  float cloud = noise( pos ) /d;
  for( int i = 0; i < ulang; i++ ){
      pos *= 2.7;
      pos.xz += waktu * float2( 1.0, -1.0 ); pos.y -= sqrt(cloud);
      d *= 3.0;
      cloud += ( noise( pos + cloud ) / d );
  }
  cloud = max( pow( cloud, 3.0 ) * -2.0 + 1.0, 0.0 );

  cloud = (cloud > 0.0) ? ( 1.0 - abs( 0.9 - cloud ) ) : 0.0;
  cloud = smoothstep( 0.7, 1.0, cloud ) * 0.8;
  if( PSInput.fogControl.x > 0.0 ){
    clouds_ = lerp( cloud, PSInput.fogColor.b, deteksi.hujan );
  }
  else {
    clouds_ = cloud;
  }
  return clamp( float3( clouds_, clouds_, clouds_), 0.0, 1.0 );
}

float3 clouds( in PS_Input PSInput, float2 p, data deteksi ) {
  const int ulang = 4;
  return PioClouds( PSInput, p, deteksi, ulang );
}

// ----------------------------------------------------------------------------------
