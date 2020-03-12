Shader "ChenZhe/ColorizeHSL"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [IntRange] _Hue ("Hue", Range(0, 360)) = 0
        [IntRange] _Saturation("Saturation", Range(0, 100)) = 25
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

            #include "UnityCG.cginc"
            #include "ColorConversionLib.cginc"
            #include "ColorAdjustmentLib.cginc"

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
                col = colorize(col, _Hue / 360.0, _Saturation / 100.0, _Lightness / 100.0);

                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
