// Modded by PioDiamond
// Please credit if you used this.
// IG : @PioDiamond
// Youtube : https://youtube.com/PioDiamond


// Reference : https://www.shadertoy.com/view/ldcSRN
#define SATURATION 1.4

#define Tonemap2Uncharted 1
#define Exposure 4.0

float3 saturation( float3 rgb, float adjustment)
{
    float gray = dot(rgb, float3(0.2125, 0.7154, 0.0721));
    return lerp(float3( gray, gray, gray ), rgb, adjustment);
}

// Source : shader sildur
float3 Uncharted2Tonemap(float3 x)
{
	const float A = 0.28,
	                     B = 0.29,
	                     C = 0.10,
	                     D = 0.20,
	                     E = 0.025,
	                     F = 0.35;
	
	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

float3 tonemap2uncharted( float3 texColor )
{
	const float W = 15.2,
	                     Contrast = 0.18;
	
	texColor *= Exposure*4.7;  // Hardcoded Exposure Adjustment
	float3 curr = Uncharted2Tonemap(texColor);
	float3 color = curr/Uncharted2Tonemap(float3(W, W, W));
	
	float spd = 1.0/Contrast;
	float3 retColor = pow(color, float3( spd, spd, spd ));
	return retColor;
}

void setColor( inout float3 c ){

	#if Tonemap2Uncharted
		c = tonemap2uncharted( c );
	#endif
		
	c = saturation( c, SATURATION );
}