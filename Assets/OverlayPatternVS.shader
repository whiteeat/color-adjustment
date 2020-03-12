Shader "ChenZhe/OverlayPatternVS"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Pattern ("Pattern", 2D) = "black" {}
        _Rotation ("Rotation", Range(0, 360)) = 0.0
        [Toggle(ENABLE_MIRROR_PATTERN)] _MirrorPattern("Should Mirror?", Float) = 1.0

        [IntRange] _Hue ("Hue", Range(0, 360)) = 0
        [IntRange] _Saturation("Saturation", Range(0, 100)) = 0
        [IntRange] _Lightness("Lightness Shift", Range(-100, 100)) = 0
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

            #pragma shader_feature_local ENABLE_MIRROR_PATTERN

            #include "UnityCG.cginc"
            #include "ColorConversionLib.cginc"
            #include "UVTransformLib.cginc"
            #include "ColorAdjustmentLib.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 patternUV : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex,
                      _Pattern;

            float4 _MainTex_ST,
                   _Pattern_ST;

            float _Rotation;

            float _Hue;
            float _Saturation;
            float _Lightness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float2 mirroredUV = mirrorUV(v.uv);

            #ifdef ENABLE_MIRROR_PATTERN
                o.patternUV = transformUV(mirroredUV, _Pattern_ST, _Rotation);
            #else
                o.patternUV = transformUV(v.uv, _Pattern_ST, _Rotation);
            #endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float3 col = tex2D(_MainTex, i.uv).rgb;

                float mask = 0.0;
                if (checkIfUV0to1(i.patternUV) > 0.0)
                {
                    mask = tex2D(_Pattern, i.patternUV).r;
                }

                col = colorize(col, _Hue / 360.0, _Saturation / 100.0, _Lightness / 100.0, mask);

                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
