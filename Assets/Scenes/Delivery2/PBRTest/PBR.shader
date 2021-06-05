Shader "Custom/PBR"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _FresnelParam ("Shininess", Range (0.01, 3)) = 1
        _Roughness ("Roughness", Range (0.01, 3)) = 1
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
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            float4 _Color;
            float _FresnelParam;
            float _Roughness;

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            //Automatically filled out by unity
            struct MeshData //Per vertex mesh data
            {
                float4 vertex : POSITION; //Vertex position
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0; //Uv coordinates
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION; //Clip space position
                float2 uv : TEXCOORD0; //We can use it to pass data (or uv data)
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float2 fresnelValue : TEXCOORD3;
            };


            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); //Local space to clip space
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.fresnelValue.x = 1 - saturate ( dot ( v.normal, o.viewDir ) );
                
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                //Fresnel section
                float3 lightVec =  normalize(_WorldSpaceLightPos0.xyz - i.vertex);
                float3 halfVec = normalize( i.viewDir + lightVec);
                float dotHL = dot(halfVec, lightVec);
                float testFresnel = pow(i.fresnelValue.x + (1 - i.fresnelValue.x) * (1 - dotHL), 5);
                testFresnel = testFresnel * _FresnelParam;
                //End of fresnel

                float topVal = _Roughness * _Roughness;
                float bottomRes = ((pow(dot(i.normal,halfVec),2)) * ((_Roughness * _Roughness) - 1)) + 1;
                bottomRes = UNITY_PI * (bottomRes * bottomRes);
                float finalRes = topVal / bottomRes;
                
                float3 normal = i.normal;
                float3 lightDir = _WorldSpaceLightPos0.xyz; // direction from the surface to the light

                float3 diffuseLight = max(0, dot(normal, lightDir)) * _LightColor0;

                float brdfVal = testFresnel * finalRes;
                
                return float4(brdfVal.xxx,1); //red
            }
            ENDCG
        }
    }
}
