Shader "Unlit/CullWithObject"
{
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "Unlit"
            Tags { "LightMode" = "UniversalForward" }

            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Global/Scripted matrix passed outside UnityPerMaterial CBUFFER
            float4x4 CullerShape;

            struct MeshData
            {
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 localpos   : TEXCOORD1;
                float4 cullerpos  : TEXCOORD2;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                // Position transformations
                o.positionCS = TransformObjectToHClip(v.vertex.xyz);
                o.localpos   = v.vertex.xyz;
                o.positionWS = TransformObjectToWorld(v.vertex.xyz);

                // Transform world-space position into culler-object space
                o.cullerpos  = mul(CullerShape, float4(o.positionWS, 1.0));

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                // Discard pixels inside the culler volume radius
                if (length(i.cullerpos.xyz) < 0.5)
                {
                    discard;
                }

                return float4(1.0, 0.0, 0.0, 1.0);
            }
            ENDHLSL
        }
    }
}