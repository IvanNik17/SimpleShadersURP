Shader "Unlit/SilhouetteEnhance"
{
    Properties
    {
        _AdditionalEnhance ("Additional Enhance", Float) = 1
        _Color ("Color", Color) = (1, 1, 1, 0.5)
    }
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Transparent" 
            "Queue" = "Transparent" 
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float _AdditionalEnhance;
                float4 _Color;
            CBUFFER_END

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                // Clip space position
                o.positionCS = TransformObjectToHClip(v.vertex.xyz);

                // Transform normal to world space (handles non-uniform scaling correctly)
                o.normalWS = TransformObjectToWorldNormal(v.normal);

                // Get world space view direction (vector from vertex to camera)
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                o.viewDirWS = GetWorldSpaceViewDir(positionWS);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float3 normalDirection = normalize(i.normalWS);
                float3 viewDirection = normalize(i.viewDirWS);

                // Fresnel / Silhouette dot calculation
                float NdotV = abs(dot(viewDirection, normalDirection));
                float dotProductPow = pow(NdotV, _AdditionalEnhance);

                // Avoid potential division by zero if dotProductPow is extremely close to 0
                float newOpacity = min(1.0, _Color.a / max(dotProductPow, 0.0001));

                return float4(_Color.rgb, newOpacity);
            }
            ENDHLSL
        }
    }
}