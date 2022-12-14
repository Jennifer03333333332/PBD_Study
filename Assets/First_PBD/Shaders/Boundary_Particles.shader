Shader "First_PBD/Boundary_Particles"
{
    Properties
    {

        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200

            CGPROGRAM
            // Physically based Standard lighting model, and enable shadows on all light types
            #pragma surface surf Standard fullforwardshadows
            //?
            #pragma multi_compile_instancing
            #pragma instancing_options procedural:setup //wiil call function setup()

            // Use shader model 3.0 target, to get nicer looking lighting
            //#pragma target 3.0

            sampler2D _MainTex;
            float4 color;
            float diameter;

            struct Input
            {
                float2 uv_MainTex;
                float4 color;
            };

    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
            StructuredBuffer<float4> positions;
    #endif

            void setup()
            {
    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
                float3 pos = positions[unity_InstanceID];
                float d = diameter;

                unity_ObjectToWorld._11_21_31_41 = float4(d, 0, 0, 0);
                unity_ObjectToWorld._12_22_32_42 = float4(0, d, 0, 0);
                unity_ObjectToWorld._13_23_33_43 = float4(0, 0, d, 0);
                unity_ObjectToWorld._14_24_34_44 = float4(pos.x, pos.y, pos.z, 1);

                unity_WorldToObject = unity_ObjectToWorld;
                unity_WorldToObject._14_24_34 *= -1;
                unity_WorldToObject._11_22_33 = 1.0f / unity_WorldToObject._11_22_33;
    #endif
            }

            half _Glossiness;
            half _Metallic;

            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
            // #pragma instancing_options assumeuniformscaling
            UNITY_INSTANCING_BUFFER_START(Props)
                // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)

            void surf(Input IN, inout SurfaceOutputStandard o)
            {
                // Albedo comes from a texture tinted by color
                //fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * color;
                o.Albedo = color.rgb; //c.rgb
                // Metallic and smoothness come from slider variables
                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
                o.Alpha = 1;//c.a;
            }
            ENDCG
        }
            FallBack "Diffuse"
}
