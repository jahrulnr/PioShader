// Modded by PioDiamond
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

#define debug 0

#if debug
void debuging( data deteksi, inout float4 diffuse ){
	float2 screen = gl_FragCoord.xy / 720.0;
	// screen.y = 1.0 - screen.y; // for MCBE

	if ( screen.x <= 0.1 && screen.y <= deteksi.siang )
		diffuse.rgb = float3( 0.7, 0.7, 0.7 ); // abu-abu
	else if ( screen.x <= 0.2 && screen.x > 0.1 && screen.y <= deteksi.pagi )
		diffuse.rgb = float3( 1.0, 0.0, -0.0 ); // merah
	else if ( screen.x <= 0.3 && screen.x > 0.2 && screen.y <= deteksi.hujan )
		diffuse.rgb = float3( 0.8, 0.4, 0.0 ); // orange
	else if ( screen.x <= 0.4 && screen.x > 0.3 && screen.y <= fogColor.b )
		diffuse.rgb = float3( 0.0, 1.0, 0.0 ); // hijau
	else if ( screen.x <= 0.45 && screen.x > 0.4 && screen.y <= uv1.x )
		diffuse.rgb = float3( 0.0, 0.8, 0.4 ); // hijau biru
	else if ( screen.x <= 0.5 && screen.x > 0.45 && screen.y <= uv1.y )
		diffuse.rgb = float3( 0.4, 0.4, 0.4 ); // hijau biru
	else if ( screen.y >= 0.0 && screen.x <= 0.5 && screen.y <= 1.0 )
		diffuse.rgb = float3( 0.2, 0.2, 0.2 ); // Luas area deteksi	

	// Batas horizontal
	if( (( screen.y >= 0.1 && screen.y <= 0.105 ) || ( screen.y >= 0.3 && screen.y <= 0.305 ) || ( screen.y >= 0.5 && screen.y <= 0.505 ) || ( screen.y >= 0.7 && screen.y <= 0.705 ) || ( screen.y >= 0.9 && screen.y <= 0.905 ))
		&& screen.x <= 0.5 )
		diffuse.rgb += float3( 1.0, 1.0, 1.0 ) * 0.4;

	if( (( screen.y >= 0.2 && screen.y <= 0.205 ) || ( screen.y >= 0.4 && screen.y <= 0.405 ) || ( screen.y >= 0.6 && screen.y <= 0.605 ) || ( screen.y >= 0.8 && screen.y <= 0.805 ))
		&& screen.x <= 0.5 )
		diffuse.rgb += float3( 1.0, 1.0, 1.0 ) * 0.2;

}
#endif