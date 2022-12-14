Shader "First_PBD/Particles"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #pragma target 4.5
           
            
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 color;
            float diameter;


#if SHADER_TARGET >= 45
            StructuredBuffer<float4> positions;
#endif
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float3 ambient : TEXCOORD1;
                float3 diffuse : TEXCOORD2;
                float3 color : TEXCOORD3;
                SHADOW_COORDS(4)
            };


            v2f vert(appdata_full v, uint instanceID : SV_InstanceID)
            {
#if SHADER_TARGET >= 45
                float4 data = positions[instanceID];
#else
                float3 data = 0;
#endif

                float3 localPosition = v.vertex.xyz * diameter;
                float3 worldPosition = data.xyz + localPosition;
                float3 worldNormal = v.normal;

                float3 ndotl = saturate(dot(worldNormal, _WorldSpaceLightPos0.xyz));
                float3 ambient = ShadeSH9(float4(worldNormal, 1.0f));
                float3 diffuse = (ndotl * _LightColor0.rgb);
                float3 color1 = color.xyz ; //v.color;// *(data.x + 4.21f) / 4.0f;   //0 black 1 white

                v2f o;
                o.pos = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0f));
                o.uv_MainTex = v.texcoord;
                o.ambient = ambient;
                o.diffuse = diffuse;
                o.color = color1;
                TRANSFER_SHADOW(o)
                    return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed4 albedo = tex2D(_MainTex, i.uv_MainTex);
                float3 lighting = i.diffuse * shadow + i.ambient;
                fixed4 output = fixed4(albedo.rgb * i.color * lighting, albedo.w);//albedo.w
                UNITY_APPLY_FOG(i.fogCoord, output);
                //output.Alpha = 0.1f;
                return output;
            }
            ENDCG
        }
    }
}
