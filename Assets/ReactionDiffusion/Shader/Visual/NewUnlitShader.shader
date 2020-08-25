// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/bumpmap" {
	Properties{
		_MainTex("Texture",   2D) = "white" {}
		_NormalTex("NormalTex", 2D) = "white" {}
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			Pass
			{
				CGPROGRAM
				// 頂点シェーダー使う時用
				#pragma vertex vert
				// フラグメントシェーダー使う時用
				#pragma fragment frag

				#include "UnityCG.cginc"

				uniform sampler2D _MainTex;
				uniform sampler2D _NormalTex;


				// 頂点シェーダーに渡すもの
				struct v_in {
					float4 vertex : POSITION; 	//頂点座標
					float4 normal : NORMAL;		//法線
					float2 uv : TEXCOORD0;		//UV
					float3 tangent : TANGENT;	//タンジェント
				};

				// 頂点シェーダーからフラグメントに渡すもの
				struct v2f {
					float4 position  : SV_POSITION;
					float2 uv        : TEXCOORD0;
					float4 light	 : COLOR1;
				};

				//接空間への変換行列を取得
				float4x4 InvTangentMatrix(
					float3 tangent,
					float3 binormal,
					float3 normal)
				{
					//接空間行列
					float4x4 mat = float4x4(float4(tangent.x,tangent.y,tangent.z , 0.0f),
									float4(binormal.x,binormal.y,binormal.z, 0.0f),
									float4(normal.x,normal.y,normal.z, 0.0f),
									float4(0,0,0,1)
									 );
					return transpose(mat);   // 転置
				}

				//頂点シェーダー
				v2f vert(v_in v)
				{
					v2f o;

					o.position = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;

					float3 nor = normalize(v.normal);
					float3 tan = normalize(v.tangent);
					float3 binor = cross(nor,tan);

					o.light = mul(mul(unity_WorldToObject,_WorldSpaceLightPos0),InvTangentMatrix(tan,binor,nor));

					return o;
				}

				float4 frag(v2f i) : COLOR
				{
					float3 normal = float4(UnpackNormal(tex2D(_NormalTex, i.uv)),1);
					//normal.xy = 0.0;
					float3 lightvec = normalize(i.light.xyz);
					float  diffuse = max(0, dot(normal, lightvec));
					return diffuse * tex2D(_MainTex, i.uv);
				}

				ENDCG
			}
	}
}
