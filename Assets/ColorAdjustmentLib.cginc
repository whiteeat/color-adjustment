#ifndef COLOR_ADJUSTMENT_LIB
#define COLOR_ADJUSTMENT_LIB

#include "ColorConversionLib.cginc"

// Photoshop Adjustment Hue/Saturation when the "Colorize" checkbox is unchecked
// col, h, s, l is -1.0 to 1.0
float3 colorShift(float3 col, float h, float s, float l, float alpha = 1.0, float mask = 1.0)
{
    float3 adjColor = linear2rgb(col);

    float cMin = min(min(adjColor.r, adjColor.g), adjColor.b);
    float cMax = max(max(adjColor.r, adjColor.g), adjColor.b);
    float delta = cMax - cMin;
    float value = cMax + cMin;
    float E = 1e-10;

    // Shift hue
    float deltaR=(((cMax - adjColor.r)/6.)+(delta/2.))/delta;
    float deltaG=(((cMax - adjColor.g)/6.)+(delta/2.))/delta;
    float deltaB=(((cMax - adjColor.b)/6.)+(delta/2.))/delta;

    float hue = 0.0;
    float saturation = 0.0;
    float lightness = value / 2.0;

    if (delta > 0.0)
    {         
        if(cMax - adjColor.r < E)
        {
            hue = deltaB - deltaG;
        }
        else if(cMax - adjColor.g < E)
        {
            hue = (1./3.) + deltaR - deltaB;
        }
        else
        { 
            hue = (2./3.) + deltaG - deltaR;
        }
        hue = frac(hue);

        if (lightness < 0.5)
        {
            saturation = delta / value;
        }
        else
        {
            saturation = delta / (2 - value);
        }
    }

    hue = frac(hue + h);
    adjColor = hsl2rgb(float3(hue, saturation, lightness));

    // Shift saturation
    // https://blog.csdn.net/xingyanxiao/article/details/48035537
    if (delta > 0.0)
    {
        float a = 0.0;
        if (s >= 0.0)
        {
            
            if ((s + saturation) >= 1.0)
            {
                a = saturation;
            }
            else
            {
                a = 1.0 - s;
            }
            a = 1.0 / a - 1.0;
            adjColor = adjColor + (adjColor - lightness) * a;
        }
        else
        {
            a = s;
            adjColor = lightness + (adjColor - lightness) * (1 + a);
        }
    }

    // Shift lightness
    // https://blog.csdn.net/xingyanxiao/article/details/48028415
    if (l > 0.0)
    {
        adjColor = adjColor * (1 - l) + l;
    }
    else if (l < 0.0)
    {
        adjColor = adjColor + adjColor * l;
    }

    adjColor = rgb2linear(adjColor);
    
    adjColor = lerp(col, adjColor, alpha);

    return lerp(col, adjColor, mask);
}

// Photoshop Adjustment Hue/Saturation when the "Colorize" checkbox is checked
// col, h, s is 0.0 to 1.0, lshift is -1.0 to 1.0
float3 colorize(float3 col, float h, float s, float lShift, float alpha = 1.0)
{
    float3 adjColor = linear2rgb(col);

    float minc = min( adjColor.r, min(adjColor.g, adjColor.b) );
    float maxc = max( adjColor.r, max(adjColor.g, adjColor.b) );

    adjColor.x = h;
    adjColor.y = s;
    adjColor.z = (minc+maxc)*0.5;
    // adjColor.z = saturate(adjColor.z + lShift); // doesn't work as photoshop colorize

    // https://stackoverflow.com/questions/4404507/algorithm-for-hue-saturation-adjustment-layer-from-photoshop
    // w is 0 to 2
    float w = lShift + 1.0;

    if (w < 1.0) 
    {
        adjColor.z = lerp(0.0, adjColor.z, w);
    }
    else    
    {
        adjColor.z = lerp(adjColor.z, 1.0, w - 1.0);
    }

    adjColor = hsl2rgb(adjColor);

    adjColor = rgb2linear(adjColor);

    return lerp(col, adjColor, alpha);
}

// XJ4 Adjust Color Reference Code
// inline half3 ComputeAlbedo(float2 uv, fixed4 c)
// {
//     fixed3 adj = saturate(tex2D(_AdjustMap, uv));
//     fixed4 adjColor = saturate(adj.r * _AdjustColor_R + adj.g * _AdjustColor_G + adj.b * _AdjustColor_B);
//     fixed adjFactor = max(max(adj.r, adj.g), adj.b);
//     fixed brightness = lerp(1, max(c.r, max(c.g, c.b)), adjColor.a);
//     adjColor.rgb = lerp(c.rgb, adjColor.rgb, adjColor.a);
//     half3 o = lerp(c.rgb, brightness * adjColor.rgb * lerp(_EmssiveMin, _EmssiveMax, abs(_SinTime.w)), adjFactor);
//     return saturate(o);
// }

// XJ4 Adjust Color Variant
float3 AdjustColor4Channel(float3 c, float4 adj, float4 color_R, float4 color_G, float4 color_B, float4 color_A)
{
    float4 adjColor = saturate(adj.r * color_R + adj.g * color_G + adj.b * color_B + adj.a * color_A);
    float adjFactor = 1.0; // Force this value to 1 according to the requirement from artists.
    float brightness = lerp(1, max(c.r, max(c.g, c.b)), adjColor.a);
    adjColor.rgb = lerp(c.rgb, adjColor.rgb, adjColor.a);
    float3 o = lerp(c.rgb, brightness * adjColor.rgb, adjFactor);
    return saturate(o);
}

float3 AdjustColor1Channel(float3 c, float alpha, float4 color)
{
    float4 adjColor = saturate(alpha * color);
    float adjFactor = 1.0; // Force this value to 1 according to the requirement from artists.
    float brightness = lerp(1, max(c.r, max(c.g, c.b)), adjColor.a);
    adjColor.rgb = lerp(c.rgb, adjColor.rgb, adjColor.a);
    float3 o = lerp(c.rgb, brightness * adjColor.rgb, adjFactor);
    return saturate(o);
}

#endif