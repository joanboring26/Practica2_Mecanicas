Shader "Custom/VignetteShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _lens_radius("Lens radius", Range(0, 1)) = 0.5
        _lens_feathering("Lens radius", Range(0, 1)) = 0.5
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
            float _lens_radius;
            float _lens_feathering;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 texcoord = i.uv;
	            float4 color = tex2D( _MainTex, i.uv);
	            float dist = distance(texcoord, float2(0.5,0.5));
                float v = smoothstep(_lens_radius,(_lens_radius-0.001)*_lens_feathering, dist);
	            return color * float4(v,v,v,1);
                //return col;
            }
            ENDCG
        }
    }
}
