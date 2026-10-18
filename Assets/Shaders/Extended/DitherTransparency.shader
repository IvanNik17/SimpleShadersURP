Shader "Unlit/DitherTransparency"
{
    Properties
    {
        _Color ("Albedo Color", Color) = (1,1,1,1)
        _DitherStrength ("Dither Strength", Range(0,1)) = 1
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

            // CBUFFER for SRP Batcher compatibility
            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float _DitherStrength;
            CBUFFER_END

            struct MeshData
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 scrPos : TEXCOORD1;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                
                // Transform object-space position to clip space
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);

                // Compute screen position for URP
                o.scrPos = ComputeScreenPos(o.positionCS);

                o.uv = v.uv;
                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float4 col = _Color;

                float4x4 thresholdMatrix =
                { 
                    1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
                    13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
                    4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
                    16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
                };

                // Perspective divide for screen-space pixel position
                float2 pixelPos = (i.scrPos.xy / i.scrPos.w) * _ScreenParams.xy;

                // UV space dither calculation
                float2 uvPos = i.uv * _ScreenParams.xy;

                // Dithering in Texture Coordinate Space
                clip(_DitherStrength - thresholdMatrix[uvPos.x % 4][uvPos.y % 4]);

                // Dithering in Screen Coordinate Space (Uncomment to use instead)
                // clip(_DitherStrength - thresholdMatrix[pixelPos.x % 4][pixelPos.y % 4]);

                return col;
            }
            ENDHLSL
        }
    }
}