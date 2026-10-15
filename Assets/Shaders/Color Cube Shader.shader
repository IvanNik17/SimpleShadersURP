Shader "Custom/Color Cube Shader"
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
 
				//nointerpolation
				float4 posObjCoords: TEXCOORD2;
				float4 posWorldCoords: TEXCOORD3;
			};
 
			float InverseLerp(float a, float b, float v) 
			{
				return (v - a) / (b - a);
			}
 
			Interpolators vert (MeshData v)
			{
				Interpolators o;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				//o.uv = v.uv;
				o.uv = mul(unity_ObjectToWorld, v.uv);
 
				// Convert local vertex position to world position
				// float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
 
				o.posObjCoords = v.vertex + float4(0.5, 0.5, 0.5, 0.0); //worldPos swap
 
				o.posWorldCoords = mul(unity_ObjectToWorld, v.vertex);
 
				o.normal = v.normal;
 
				return o;
			}
 
			float4 frag(Interpolators i) : SV_Target
			{
				//Mix UVs and selected color
				/*float4 mixWithColor = float4(i.uv.xyx, 1) + _Color;
				return mixWithColor;*/
 
				//Output grayscale object position coordinates of vertices
				/*float grayscale = (i.posObjCoords.x + i.posObjCoords.y + i.posObjCoords.z) / 3;
				return float4(grayscale, grayscale, grayscale, 1);*/
 
				//Output CMY color space object position coordinates of vertices
				/*float3 pureWhite = float3(1,1,1);
				float3 cmy = pureWhite - i.posObjCoords;
				return float4(cmy, 1);*/
 
				//Output HSV color space object positon coordinates of vertices
				/*float H = 180.0 + degrees(atan2(i.posObjCoords.z, i.posObjCoords.x));
				float S = 2.0 * sqrt(i.posObjCoords.x * i.posObjCoords.x + i.posObjCoords.z * i.posObjCoords.z);
				float V = (i.posObjCoords.y + 1.0) / 2.0;
				return float4(H, S, V, 1);*/
 
				return i.posObjCoords;
 
				/*float4 outside01 = i.uv.xxxx * 4;
				return frac(outside01);*/
			}
			ENDHLSL
		}
	}}
