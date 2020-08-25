Shader "Custom/ReactionDiffusion"
{
		Properties{
			_MainTex("Texture", 2D) = "white" {}
			_BumpMap("Bumpmap", 2D) = "bump" {}
			_Cube("Cubemap", 2D) = "" {}
			_Weight("Dispalce-Weight", float) = 1.0
		}
		SubShader{
		  Tags { "RenderType" = "Opaque" }
		  CGPROGRAM
		  #pragma surface surf Lambert
		  struct Input {
			  float2 uv_MainTex;
			  float2 uv_BumpMap;
			  float3 worldRefl;
			  INTERNAL_DATA
		  };
		  sampler2D _MainTex;
		  sampler2D _BumpMap;
		  samplerCUBE _Cube;
		  float _Weight;
		  void surf(Input IN, inout SurfaceOutput o) {
			  

			  float d = tex2D(_BumpMap, IN.uv_MainTex).rgb ;
			  d *= _Weight;


			  float2 uv = IN.uv_MainTex;
			  fixed4 c = float4(0.0.xxxx);
			  /*
			  float att = 0.75;
			  float level = 1.0;
			  float sum = 0.0;
			  fixed4 c = tex2D(_MainTex, uv);
			  for (int i = 0; i < 10; i++) {
				  uv.x = uv.x + d * att;

				  c.rgb += tex2D(_MainTex, uv).rgb * level;
				  sum += level;
				  level *= att;
				  
			  }
			  
			  c.rgb /= sum;
			  */


			  //uv.x = uv.x + d;
			  c.rgb = tex2D(_MainTex, uv).rgb;
			  o.Albedo = c;
			  


			  float3 n =UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			  //o.Normal = UnpackScaleNormal( float4(0.0, 0.0, n.x, 1.0), _Amp);
			  //o.Emission = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal)).rgb;
		  }
		  ENDCG
	}
		Fallback "Diffuse"
}