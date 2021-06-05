Shader "Custom/ToneMapping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Exposure("Exposure", Range(0, 10)) = 0.6
        _Gamma("Gamma", Range(0, 5)) = 2.2
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _Exposure;
            float _Gamma;

            fixed4 frag (v2f i) : SV_Target
            {
                const float g = _Gamma;
                float3 sceneColor = tex2D(_MainTex, i.uv).rgb;
                float3 m = float3(1,1,1) - exp(-sceneColor * _Exposure);
                float gamCorr = 1.0 / g;
                m = pow(m, float3(gamCorr,gamCorr,gamCorr));
            
                return  float4(m, 1.0);
            }
            ENDCG
        }
    }
}
