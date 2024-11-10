// Noise Source : https://www.shadertoy.com/view/tstXzS
float random(float2 co)
{
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(co.xy, float2(a,b));
    float sn= fmod(dt,3.14);
    return frac(sin(sn) * c);
}

float noise(in float2 st) {
    float2 i = floor(st);
    float2 f = frac(st);

    float a = random(i);
    float b = random(i + float2(1.0, 0.0));
    float c = random(i + float2(0.0, 1.0));
    float d = random(i + float2(1.0, 1.0));

    float2 u = f * f * (3.0 - 2.0 * f);

    return lerp(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}
// -----------------------------------------------------

// Noise Source : https://www.shadertoy.com/view/4dS3Wd
float hash(float p) { 
    p = frac(p * 0.011); 
    p *= p + 7.5; 
    p *= p + p; 
    return frac(p); 
}

float noise(float3 x) {
    const float3 step = float3(110.0, 241.0, 171.0);

    float3 i = floor(x);
    float3 f = frac(x);

    float n = dot(i, step);

    float3 u = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(lerp( hash(n + dot(step, float3(0, 0, 0))), hash(n + dot(step, float3(1, 0, 0))), u.x),
                   lerp( hash(n + dot(step, float3(0, 1, 0))), hash(n + dot(step, float3(1, 1, 0))), u.x), u.y),
               lerp(lerp( hash(n + dot(step, float3(0, 0, 1))), hash(n + dot(step, float3(1, 0, 1))), u.x),
                   lerp( hash(n + dot(step, float3(0, 1, 1))), hash(n + dot(step, float3(1, 1, 1))), u.x), u.y), u.z);
}
