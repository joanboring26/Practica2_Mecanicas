Shader "Hidden/Custom/TestEffect"
{
    HLSLINCLUDE
    // Stdlib.hlsl holds pre-configured vertex shaders (VertDefault), varying structs (VaryingsDefault), and most of the data you
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/Stdlib.hlsl"
    
    TEXTURE2D_SAMPLER2D(_Maintex, sampler_Maintex);
    
    float _intensity;
    float _lens_radius;
    float _lens_feathering;
    float4 Frag (VaryingsDefault i) : SV_Target
    {
        float2 texcoord = i.texcoord;
	    float4 color = SAMPLE_TEXTURE2D(_Maintex, sampler_Maintex, i.texcoord);
	    float dist = distance(texcoord, float2(0.5,0.5));
        float v = smoothstep(_lens_radius,(_lens_radius-0.001)*_lens_feathering, dist);
	    return tex2D(sampler_Maintex, texcoord);
        //float4 color = SAMPLE_TEXTURE2D(_Maintex, sampler_Maintex, i.texcoord);
        //float4 color2 = float4(1,1,1,1) - color;
        //color.rgb = lerp(color.rgb, color2.rgb, _intensity.xxx);
        //// Return the result
        //return color;
    }
    ENDHLSL
    
    SubShader
    {
        Cull Off zwrite Off ZTest Always
            Pass
        {
            HLSLPROGRAM
                #pragma vertex VertDefault
                #pragma fragment Frag 
            ENDHLSL
        }
    }
}
