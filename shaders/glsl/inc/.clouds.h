// Created by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond


  #define rotate(x) float2x2(cos( x ), -sin( x ), sin( x ), cos( x ))

// "Clouds" Created by PioDiamond
// ----------------------------------------------------------------------------------
float3 PioClouds( float2 p, data deteksi, int ulang );

float3 clouds( float2 p, data deteksi ) {
  const int ulang = 4;
  return PioClouds( p, deteksi, ulang );
}

float testDither( vec3 v ){
	float x = dot( floor(v * 400.0), vec3( 1.0, 200.0, 115.0 ));
	return hash(x) * 0.05;
}

float3 PioClouds( float2 p, data deteksi, int ulang ) {
  const float skala = 6.0;
  const float cepat = 0.02;
  highp float waktu = ( cepat * TIME );
/**/
// 3D
    float3 pos = vec3( p.x, length(p), p.y ); pos = pos / (pos.y + 0.3); pos.xz *= skala; pos.x *= 0.6;
    highp float clouds_;
    float d = 1.0;
    pos.xz += waktu * vec2( 1.0, -1.0 );
    highp float cloud = noise( pos ) /d;
    for( int i = 0; i < ulang; i++ ){
        pos *= 2.7;
        pos.xz += waktu * vec2( 1.0, -1.0 ); pos.y -= sqrt(cloud);
        d *= 3.0;
        cloud += ( noise( pos + cloud ) / d );
    }
    cloud = max( pow( cloud, 3.0 ) * -2.0 + 1.0, 0.0 );

    cloud = (cloud > 0.0) ? ( 1.0 - abs( 0.9 - cloud ) ) : 0.0;
    cloud = smoothstep( 0.7, 1.0, cloud ) * 0.8;
    if( fogControl.x > 0.0 ){
      clouds_ = lerp( cloud, fogColor.b, deteksi.hujan );
    }
    else {
      clouds_ = cloud;
    }
    return clamp( float3( clouds_, clouds_, clouds_), 0.0, 1.0 );
}
// ----------------------------------------------------------------------------------
