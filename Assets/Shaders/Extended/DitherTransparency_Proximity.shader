Shader "Unlit/DitherTransparency_Proximity"
{
    Properties
    {
        _Color ("Albedo Color", Color) = (1,1,1,1)
        _DitherStrength ("Global Dither Strength", Range(0,1)) = 1
        _CullCenter ("Target Object Position (WS)", Vector) = (0,0,0,0)
        _CullRadius ("Proximity Fade Radius", Float) = 3.0
    }
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

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float _DitherStrength;
                float4 _CullCenter;
                float _CullRadius;
            CBUFFER_END

            struct MeshData
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                
                // Transform to clip space and world space
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.positionWS = TransformObjectToWorld(v.positionOS.xyz);

                o.uv = v.uv;
                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float4 col = _Color;

                // 4x4 Bayer Matrix for dithering
                float4x4 thresholdMatrix =
                { 
                    1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
                    13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
                    4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
                    16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
                };

                // Calculate distance between this fragment (World Space) and target object position
                float dist = distance(i.positionWS, _CullCenter.xyz);

                // Map distance to a 0..1 factor: 
                // where it can be either 0 = at or inside target position (fully transparent/dithered)
                // or it can be 1 = at or outside _CullRadius distance (fully solid)
                float proximityAlpha = saturate(dist / max(_CullRadius, 0.0001));

                // Combine the init strength with proximity factor that we have calculated
                float localDitherStrength = _DitherStrength * proximityAlpha;

                // Dither pattern calculation using screen pixel space (or UV space)
                float2 pixelPos = i.positionCS.xy;
                int x = (int)fmod(pixelPos.x, 4.0);
                int y = (int)fmod(pixelPos.y, 4.0);

                // Clip pixels where proximity-modified strength falls below matrix threshold
                clip(localDitherStrength - thresholdMatrix[x][y]);

                return col;
            }
            ENDHLSL
        }
    }
}