#ifndef COLOR_CONVERSION_LIB
#define COLOR_CONVERSION_LIB

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

// https://www.shadertoy.com/view/wt23Rt
//RGB to HSL (hue, saturation, lightness/luminance).
//Source: https://gist.github.com/yiwenl/745bfea7f04c456e0101
float3 rgb2hslRef(float3 c)
{
	float cMin=min(min(c.r,c.g),c.b),
	      cMax=max(max(c.r,c.g),c.b),
	      delta=cMax-cMin;
	float3 hsl=float3(0.,0.,(cMax+cMin)/2.);
    float E = 1e-10;
	if(delta > 0.0) //If it has chroma and isn't gray.
    {
		if(hsl.z<.5)
        {
			hsl.y = delta/(cMax+cMin); //Saturation.
		}
        else{
			hsl.y = delta/(2.-cMax-cMin); //Saturation.
		}
		float deltaR=(((cMax-c.r)/6.)+(delta/2.))/delta,
		      deltaG=(((cMax-c.g)/6.)+(delta/2.))/delta,
		      deltaB=(((cMax-c.b)/6.)+(delta/2.))/delta;
		//Hue.
		if(cMax - c.r < E)
        {
			hsl.x=deltaB-deltaG;
		}
        else if(cMax - c.g < E)
        {
			hsl.x=(1./3.)+deltaR-deltaB;
		}
        else
        { //if(c.b==cMax){
			hsl.x=(2./3.)+deltaG-deltaR;
		}
		hsl.x=frac(hsl.x);
	}
	return hsl;
}

float3 hsl2rgbRef(float3 hsl)
{
    float E = 1e-10;
	if(hsl.y < E){
		return float3(hsl.z, hsl.z, hsl.z); //Luminance.
	}else{
		float b;
		if(hsl.z<.5){
			b=hsl.z*(1.+hsl.y);
		}else{
			b=hsl.z+hsl.y-hsl.y*hsl.z;
		}
		float a=2.*hsl.z-b;
		return a+hue2rgb(hsl.x)*(b-a);
	}
}

// http://www.chilliant.com/rgb2hsv.html
float3 RGBtoHCV(in float3 RGB)
{
    float Epsilon = 1e-10;
    // Based on work by Sam Hocevar and Emil Persson
    float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0/3.0) : float4(RGB.gb, 0.0, -1.0/3.0);
    float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
    float C = Q.x - min(Q.w, Q.y);
    float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
    return float3(H, C, Q.x);
}

float3 rgb2hsl(in float3 RGB)
{
    float Epsilon = 1e-10;
    float3 HCV = RGBtoHCV(RGB);
    float L = HCV.z - HCV.y * 0.5;
    float S = HCV.y / (1 - abs(L * 2 - 1) + Epsilon);
    return float3(HCV.x, S, L);
}

float3 hsl2rgb(in float3 HSL)
{
    float3 RGB = hue2rgb(HSL.x);
    float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
    return (RGB - 0.5) * C + HSL.z;
}

#endif