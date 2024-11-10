// Modded by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond

// Source : https://www.shadertoy.com/view/ldSXWK
float noise(float t)
{
	return frac(cos(t) * 3800.);
}

float3 lensflare(float2 u, float2 pos)
{
	float2 main = u-pos;
	float2 uvd = u * length(u);

	float ang = atan2( main.y, main.x );
	float dist = length(u);
	dist = pow( dist, .01);
	float n = noise( 0. );

	float f0 = (1.0/(length(u-12.)*16.0+1.0)) * 2.;

	f0 = f0*(sin((n*2.0)*12.0)*.1+dist*.1+.8);

	float f2 = max(1.0/(1.0+32.0*pow(length(uvd+0.8*pos),2.0)),.0)*00.25;
	float f22 = max(1.0/(1.0+32.0*pow(length(uvd+0.85*pos),2.0)),.0)*00.23;
	float f23 = max(1.0/(1.0+32.0*pow(length(uvd+0.9*pos),2.0)),.0)*00.21;

	float2 uvx = lerp(u,uvd,-0.5);

	float f4 = max(0.01-pow(length(uvx+0.45*pos),2.4),.0)*6.0;
	float f42 = max(0.01-pow(length(uvx+0.5*pos),2.4),.0)*5.0;
	float f43 = max(0.01-pow(length(uvx+0.55*pos),2.4),.0)*3.0;

	uvx = lerp(u,uvd,-.4);

	float f5 = max(0.01-pow(length(uvx+0.3*pos),5.5),.0)*2.0;
	float f52 = max(0.01-pow(length(uvx+0.5*pos),5.5),.0)*2.0;
	float f53 = max(0.01-pow(length(uvx+0.7*pos),5.5),.0)*2.0;

	uvx = lerp(u,uvd,-0.5);

	float f6 = max(0.01-pow(length(uvx+0.1*pos),1.6),.0)*6.0;
	float f62 = max(0.01-pow(length(uvx+0.125*pos),1.6),.0)*3.0;
	float f63 = max(0.01-pow(length(uvx+0.15*pos),1.6),.0)*5.0;

	float3 c = float3( 0.0, 0.0, 0.0 );
	c.r += f2 + f4 + f5 + f6; 
	c.g += f22 + f42 + f52 + f62; 
	c.b += f23 + f43 + f53 + f63;
	c += float3( f0, f0, f0 );

	return c;
}

float3 cc( float3 color, float factor, float factor2) // color modifier
{
	float w = color.x + color.y + color.z;
	return lerp( color, float3( w, w, w ) * factor, w * factor2 );
}
// ----------------------