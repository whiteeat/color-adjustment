#ifndef UV_TRANSFORM_LIB
#define UV_TRANSFORM_LIB

#include "UnityCG.cginc"

float2 scaleUV(float2 uv, float2 scale)
{
    return uv * scale;
}

float2 translateUV(float2 uv, float2 translation)
{
    return uv + translation;
}

// Rotation is in degree. 
float2 rotateUV(float2 uv, float rotation)
{
    // rotating UV
    const float Deg2Rad = (UNITY_PI * 2.0) / 360.0;

    float rotationRadians = rotation * Deg2Rad; // convert degrees to radians
    float s = sin(rotationRadians);
    float c = cos(rotationRadians);

    float2x2 rotationMatrix = float2x2(c, -s, s, c); // construct simple rotation matrix

    uv = mul(rotationMatrix, uv);

    return uv;
}

float2 transformUV(float2 uv, float4 ST, float rotation)
{
    uv = translateUV(uv, -ST.zw);
    uv = translateUV(uv, -0.5);
    uv = rotateUV(uv, rotation);
    uv = scaleUV(uv, 1.0 / ST.xy);
    return uv = translateUV(uv, 0.5);
}

float2 mirrorUV(float2 uv)
{
    if (uv.x >= 0.5)
    {
        uv.x = 1 - uv.x;
    }
    return uv;
}

// If 0.0 to 1.0, return 1.0. Otherwise return -1.0 
float checkIfUV0to1(float2 uv)
{   
    float result = -1.0;

    if (uv.x >= 0.0 &&
        uv.x <= 1.0 &&
        uv.y >= 0.0 &&
        uv.y <= 1.0)
    {
        result = 1.0;
    }

    return result;
}

#endif