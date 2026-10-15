Shader "Custom/Basic Test Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
 
        Pass
        {
            Cull Off
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
 
            // Required for SRP Batcher compatibility in URP
            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
            CBUFFER_END
 
            struct MeshData
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };
 
            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 normal: TEXCOORD1;
                float4 posObjCoords: TEXCOORD2;
            };
 
            float InverseLerp(float a, float b, float v) 
            {
                return (v - a) / (b - a);
            }
 
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = mul(unity_ObjectToWorld, v.uv);
 
                o.posObjCoords = v.vertex;
                o.normal = v.normal;
 
                return o;
            }
 
            float4 frag(Interpolators i) : SV_Target
            {
                // Using and not using if statements
                if (i.posObjCoords.y > 0.0)
                {
                    discard;
                }
 
                /*float maskDiscard = i.posObjCoords.y < 0.0;
                clip(maskDiscard - 0.000001);*/
 
                return i.uv;
            }
            ENDHLSL
        }
    }
}
