Shader "ChenZhe/ColorShiftHSL"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [IntRange] _Hue ("Hue", Range(-180, 180)) = 0
        [IntRange] _Saturation("Saturation", range(-100, 100)) = 0
        [IntRange] _Lightness("Lightness Shift", range(-100, 100)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "ColorConversionLib.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Hue;
            float _Saturation;
            float _Lightness;

            // col, h, s, l is -1.0 to 1.0
            float3 colorShift(float3 col, float h, float s, float l, float alpha = 1.0)
            {
                float3 adjColor = linear2rgb(col);
                adjColor = rgb2hsl(adjColor);

                adjColor.x = frac(adjColor.x + h);
                adjColor.y = saturate(adjColor.y + s);
                // adjColor.z = saturate(adjColor.z + l); // doesn't work as photoshop colorize

                // https://stackoverflow.com/questions/4404507/algorithm-for-hue-saturation-adjustment-layer-from-photoshop
                // w is 0 to 2
                float w = l + 1.0;

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float3 col = tex2D(_MainTex, i.uv).rgb;
                col = colorShift(col, _Hue / 360.0, _Saturation / 100.0, _Lightness / 100.0);

                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
