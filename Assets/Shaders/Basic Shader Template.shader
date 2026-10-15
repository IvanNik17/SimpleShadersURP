Shader "Custom/Basic Shader Template"
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
			ZWrite On
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma enable_d3d11_debug_symbols
 
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
			};
 
			float InverseLerp(float a, float b, float v) 
			{
				return (v - a) / (b - a);
			}
 
			Interpolators vert (MeshData v)
			{
				Interpolators o;
				// URP clip space transformation
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.uv = v.uv;
				o.normal = v.normal;

				return o;
			}
 
			float4 frag (Interpolators i) : SV_Target
			{
				return i.uv;
			}
			ENDHLSL
		}
	}
}
