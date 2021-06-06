Shader "Custom/PBRTextured"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Metallic ("Metallic", Range (0, 1)) = 1
        _FresnelParam ("Shininess", Range (0.01, 3)) = 1
        _Roughness ("Roughness", Range (0.01, 3)) = 1
    }
    SubShader
    {
        Tags {	"RenderType"="Opaque" 
        		"LightMode" = "ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            

            //float4 _Color;
            
            float _FresnelParam;
            float _Roughness;
            float _Metallic;

            sampler2D _MainTex;
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
                float4 pos : SV_POSITION; //Clip space position
                float3 posWorld : TEXCOORD4; //Clip space position
                float2 uv : TEXCOORD0; //We can use it to pass data (or uv data)
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float2 fresnelValue : TEXCOORD3;
            	LIGHTING_COORDS(4,5)
            };


            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.pos = UnityObjectToClipPos(v.vertex); //Local space to clip space
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex));
                o.fresnelValue.x = 1 - saturate ( dot ( v.normal, o.viewDir ) );
                o.uv = v.uv;
            	TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
            	
                //Establish base vars
                float3 diffuseColor = tex2D(_MainTex, i.uv) * (1-_Metallic);
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.rgb;
                
                //Fresnel section
                float3 lightVec =  normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 halfVec = normalize( i.viewDir + lightVec);
                float dotHL = dot(halfVec, lightVec);
                float testFresnel = pow(i.fresnelValue.x + (1 - i.fresnelValue.x) * (1 - dotHL), 5);
                testFresnel = testFresnel * _FresnelParam;
                //End of fresnel

                //GGX(Isotrópico):
                float topVal = _Roughness * _Roughness;
                float bottomRes = ((pow(dot(i.normal,halfVec),2)) * ((_Roughness * _Roughness) - 1)) + 1;
                bottomRes = UNITY_PI * (bottomRes * bottomRes);
                float finalRes = topVal / bottomRes;
                //

                //Neumann
                float neumannResult =
                    (dot(i.normal,lightVec) * dot(i.normal, i.viewDir))
                    /
                    max(dot(i.normal,lightVec),dot(i.normal, i.viewDir));
                //
                
                float3 specularity = (finalRes * testFresnel * neumannResult) / (4 * (  dot(i.normal,lightVec) * dot(i.normal, i.viewDir)));

                float3 lightingModel = (diffuseColor + specularity);
                lightingModel *= dot(i.normal,lightVec);
                float4 finalDiffuse = float4(lightingModel * attenColor,1);
                return finalDiffuse;
            }

            
            ENDCG
        }

        // Shadowcast pass
		Pass 
		{
			Name "CastShadow"
			Tags { "LightMode" = "ShadowCaster" }
	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
	
			struct interpolator
			{ 
				V2F_SHADOW_CASTER;
			};
	
			interpolator vert( appdata_base v )
			{
				interpolator o;
				TRANSFER_SHADOW_CASTER(o)
				return o;
			}
	
			float4 frag( interpolator i ) : COLOR
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
        
    }
}
