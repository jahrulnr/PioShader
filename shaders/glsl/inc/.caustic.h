// Modded by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

// Source : https://www.shadertoy.com/view/MdlXz8
float caustic( in data deteksi ) {

  float SCALE = 0.5;
  float TAU = 6.283;
  int MAX_ITER = 3;

	float time = TIME * .5+23.0;
    // uv should be the 0-1 uv of texture...
	float2 uv;
  	if (fract( pos.y ) > 0.0){
  	if (fract( pos.x ) > 0.0){
  	  uv = (pos.xy - 8.0) * SCALE;
  	} else {
  	  uv = (pos.yz - 8.0) * SCALE;
  	}}
  	else {
  	  uv = (pos.xz - 8.0) * SCALE;
  	}
  	
  	float2 p;
  	float2 i;
  	p = i = fmod( uv * TAU, TAU)-250.0;
	
	float c = 1.0;
	float inten = .005;
	float t;

	for (int n = 0; n < MAX_ITER; n++) 
	{
		t = time * (1.0 - (3.5 / float(n+1)));
		i = p + float2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0 / length( float2( p.x / ( sin( i.x+t ) / inten ), p.y / ( cos( i.y + t ) / inten ) ) );
	}
	c /= float(MAX_ITER);
	c = 1.17-pow(c, 1.4);
	return clamp(pow(abs(c), 8.0), 0.0, 0.7 ) * max(sqrt(uv1.y), 0.4) * ( 1.0 - uv1.x ) * deteksi.siang;
}