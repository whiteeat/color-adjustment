#ifndef HSV_LIB
#define HSV_LIB

// https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Colorspace-Conversion-Node.html
float3 rgb2linear(float3 In)
{
    float3 linearRGBLo = In / 12.92;;
    float3 linearRGBHi = pow(max(abs((In + 0.055) / 1.055), 1.192092896e-07), float3(2.4, 2.4, 2.4));
    return float3(In <= 0.04045) ? linearRGBLo : linearRGBHi;
}

float3 linear2rgb(float3 In)
{
    float3 sRGBLo = In * 12.92;
    float3 sRGBHi = (pow(max(abs(In), 1.192092896e-07), float3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
    return float3(In <= 0.0031308) ? sRGBLo : sRGBHi;
}

float3 hsv2rgb(float3 In)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 P = abs(frac(In.xxx + K.xyz) * 6.0 - K.www);
    return In.z * lerp(K.xxx, saturate(P - K.xxx), In.y);
}

float3 rgb2hsv(float3 In)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
    float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
    float D = Q.x - min(Q.w, Q.y);
    float  E = 1e-10;
    return float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), Q.x);
}

float3 rgb2linear_ref(float3 rgb)
{
    return pow(rgb, 2.2);
}

float3 linear2rgb_ref(float3 linearRgb)
{
    return pow(linearRgb, 1 / 2.2);
}


// https://www.ronja-tutorials.com/2019/04/16/hsv-colorspace.html
float3 hue2rgb(float hue) {
    hue = frac(hue); //only use fractional part
    float r = abs(hue * 6 - 3) - 1; //red
    float g = 2 - abs(hue * 6 - 2); //green
    float b = 2 - abs(hue * 6 - 4); //blue
    float3 rgb = float3(r,g,b); //combine components
    rgb = saturate(rgb); //clamp between 0 and 1
    return rgb;
}

float3 hsv2rgbRef(float3 hsv)
{
    float3 rgb = hue2rgb(hsv.x); //apply hue
    rgb = lerp(1, rgb, hsv.y); //apply saturation
    rgb = rgb * hsv.z; //apply value
    return rgb;
}

float3 rgb2hsvRef(float3 rgb)
{
    float maxComponent = max(rgb.r, max(rgb.g, rgb.b));
    float minComponent = min(rgb.r, min(rgb.g, rgb.b));
    float diff = maxComponent - minComponent;
    float hue = 0;
    if(maxComponent == rgb.r) {
        hue = 0+(rgb.g-rgb.b)/diff;
        } else if(maxComponent == rgb.g) {
        hue = 2+(rgb.b-rgb.r)/diff;
        } else if(maxComponent == rgb.b) {
        hue = 4+(rgb.r-rgb.g)/diff;
    }
    hue = frac(hue / 6);
    float saturation = diff / maxComponent;
    float value = maxComponent;
    return float3(hue, saturation, value);
}

// https://www.shadertoy.com/view/lsS3Wc
float3 rgb2hsl(float3 col)
{
    float minc = min( col.r, min(col.g, col.b) );
    float maxc = max( col.r, max(col.g, col.b) );
    float3 mask = step(col.grr,col.rgb) * step(col.bbg,col.rgb);
    float E = 1e-10;
    float3 h = mask * (float3(0.0,2.0,4.0) + (col.gbr-col.brg)/(maxc-minc + E)) / 6.0;
    return float3( frac( 1.0 + h.x + h.y + h.z ),              // H
    (maxc-minc)/(1.0-abs(minc+maxc-1.0) + E),  // S
    (minc+maxc)*0.5 );                           // L
}

float3 hsl2rgb(float3 c)
{
    float3 rgb = clamp( abs(fmod(c.x*6.0+float3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
    return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}

#endif