// Modded by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

// Source : https://www.geeks3d.com/20110316/shader-library-simple-2d-effects-sphere-and-ripple-in-glsl/
// Modded by PioDiamond

float rWater( vec2 uv, float timer ) {
	vec2 p = -1.0 + 2.0 * uv; 
	float len = length( p ); 
	float r;
	float dist;
	if( len < 0.5 ){
		dist = ( 0.5 - abs( 0.5 - len * 2.0 ) );	
	  uv = ( p / len ) * cos( len * 25.0 - TIME * 15.0 ) * 0.5; 
	  r = uv.x * dist * sin( TIME * 3.0 + timer );
	  r = max( 0.0, r );
	}
	else{
		r = 0.0;
	}
	return r;
}

float splash( vec2 pos ){
	float rWs = rWater( pos + vec2( 0.5, 0.5 ), 2.0 );
	rWs = max( rWs, rWater( pos + vec2( 0.5, 0.5 ), 2.0 ) );
	rWs = max( rWs, rWater( pos + vec2( -0.5, 0.5 ), 2.0 ) );
	rWs = max( rWs, rWater( pos + vec2( 0.5, -0.5 ), 2.0 ) );
	rWs = max( rWs, rWater( pos - vec2( 0.5, 0.5 ), 2.0 ) );
	
	rWs = max( rWs, rWater( pos + vec2( 0.3, 0.2 ), 0.5 ) );
	rWs = max( rWs, rWater( pos + vec2( 0.2, -0.3 ), 2.5 ) );
	rWs = max( rWs, rWater( pos + vec2( -0.3, 0.1 ), 1.5 ) );
	rWs = max( rWs, rWater( pos - vec2( 0.2, 0.1 ), 3.5 ) );
	
	return rWs;
}

float rain(){
   float c = 0.0;
   if( fract( pos.y ) == 0.0 || fract( pos.y ) == 0.5 ) {
      float eff = splash( fract( pos.xz ) );
      c = mix( 0.0, eff, max( uv1.y - 0.8, 0.0 ) * 5.0 );
   }
   return c;
}
