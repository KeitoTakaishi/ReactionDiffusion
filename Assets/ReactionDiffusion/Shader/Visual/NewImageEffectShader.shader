Shader "Hidden/NewImageEffectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Power("BumpPower", float) = 1.0
    }
    SubShader
    {
        // No culling or depth
        //Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

			sampler2D _MainTex;
			float _Power;
            v2f vert (appdata v)
            {
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				float3 normal = normalize(v.normal);
				float bump = tex2Dlod(_MainTex, float4(o.uv.xy, 0, 0)).r;
				float4 vert = v.vertex;
				
				vert.xyz = vert.xyz + (normal.xyz * _Power * bump);
                o.vertex = UnityObjectToClipPos(vert);
                o.uv = v.uv;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                //col.rgb = 1 - col.rgb;
                return col;
            }
            ENDCG
        }
    }
}
