//[Vertex shader]


#define __HAVE_MATRIX_MULTIPLE_SCALAR_CONSTRUCTORS__
#include <metal_stdlib>

using namespace metal;

#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/GlobalConstants_MTL.shdh"
#include "Shaders/GlobalConstants_PS_MTL.shdh"

typedef struct
{
	float3 Position SV_POSITION0;
	float4 LocalQTangent NORMAL0;
	float2 TexCoords0 TEXCOORD0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position]];
	float3 ViewNormal;
	float2 TexCoords0;
} VertexOutput;

struct LocalUniformsVS
{
	float4x4 WorldMatrix;
};

vertex VertexOutput Materials_OdinWater_IceElemental_Material_01_ST_DEF_Metal_vertexMain(constant LocalUniformsVS& uniforms [[buffer(5)]],
	constant PerView& perView [[buffer(6)]],
	VertexInput In [[stage_in]])
{
	VertexOutput Out;

	//World space position
	float4 worldPosition = (uniforms.WorldMatrix * float4(In.Position, 1.0f));

	//Projected position
	float4 projectedPosition = (perView.global_ViewProjection * worldPosition);

	//Pass projected position to pixel shader
	Out.ProjectedPosition = projectedPosition;

	//Compute local tangent frame
	float3x3 LocalTangentFrame = GetTangentFrame(In.LocalQTangent);

	float3 LocalNormal = LocalTangentFrame[2];

	//Normalize Local Normal
	float3 localNormalNormalized = normalize(LocalNormal);

	//World space Normal
	float3 worldNormal = (float3x3(uniforms.WorldMatrix[0].xyz, uniforms.WorldMatrix[1].xyz, uniforms.WorldMatrix[2].xyz) * localNormalNormalized);

	//Normalize World Normal
	float3 worldNormalNormalized = normalize(worldNormal);

	float3 viewSpaceNormal = (float3x3(perView.global_View[0].xyz, perView.global_View[1].xyz, perView.global_View[2].xyz) * worldNormalNormalized);

	Out.ViewNormal = viewSpaceNormal;

	Out.TexCoords0 = In.TexCoords0;

	return Out;
}


//[Fragment shader]


#include "Shaders/Metal/PBR.shdh"

typedef struct
{
	float4 Color0 [[color(0)]];
	float4 Color1 [[color(1)]];
	float4 Color2 [[color(2)]];
	float4 Color3 [[color(3)]];
} PixelOutput;

struct LocalUniformsPS
{
	float _OpacityFade;
};

static void CalculateMatBaseColor(float2 in_0,
	thread float3& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_d5f0bbd13eaa417daf2f7f12ee516b17_DefaultWrapSampler)
{
	float4 Local0 = Texture2DParameter_d5f0bbd13eaa417daf2f7f12ee516b17_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local0] Get needed components
	float3 Local1 = Local0.xyz;
	float Local2 = Local0.w;
	out_0 = Local1;
}

static void CalculateMatMetalMask(float2 in_0,
	thread float& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_e34b4ff04cbb4ec6b464e7b0efd7be9d_DefaultWrapSampler)
{
	float4 Local0 = Texture2DParameter_e34b4ff04cbb4ec6b464e7b0efd7be9d_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local0] Convert normalmaps to tangent space vectors
	Local0.xyzw = Local0.wzyx;
	Local0.xyz = ((Local0.xyz * 2.0f) - 1.0f);
	Local0.z = -(Local0.z);
	Local0.xyz = normalize(Local0.xyz);
	//[Local0] Get needed components
	float3 Local1 = Local0.xyz;
	out_0 = Local1.x;
}

static void CalculateMatReflectance(float2 in_0,
	thread float& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_d5f0bbd13eaa417daf2f7f12ee516b17_DefaultWrapSampler)
{
	float4 Local0 = Texture2DParameter_d5f0bbd13eaa417daf2f7f12ee516b17_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local0] Get needed components
	float3 Local1 = Local0.xyz;
	float Local2 = Local0.w;
	out_0 = Local2;
}

static void CalculateMatRoughness(float2 in_0,
	thread float& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_d05006397acf4612938d1d4da6812f16_DefaultWrapSampler)
{
	float4 Local0 = Texture2DParameter_d05006397acf4612938d1d4da6812f16_DefaultWrapSampler.sample(_DefaultWrapSampler, in_0);
	//[Local0] Get needed components
	float3 Local1 = Local0.xyz;
	out_0 = Local1.x;
}

fragment PixelOutput Materials_OdinWater_IceElemental_Material_01_ST_DEF_Metal_fragmentMain(constant LocalUniformsPS& uniforms,
	VertexOutput In [[stage_in]],
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_d5f0bbd13eaa417daf2f7f12ee516b17_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_e34b4ff04cbb4ec6b464e7b0efd7be9d_DefaultWrapSampler,
	texture2d<float> Texture2DParameter_d05006397acf4612938d1d4da6812f16_DefaultWrapSampler)
{
	PixelOutput Out;

	float3 viewNormalNormalized = normalize(In.ViewNormal);

	float3 matBaseColor;
	CalculateMatBaseColor(In.TexCoords0, matBaseColor, _DefaultWrapSampler, Texture2DParameter_d5f0bbd13eaa417daf2f7f12ee516b17_DefaultWrapSampler);
	float matMetalMask;
	CalculateMatMetalMask(In.TexCoords0, matMetalMask, _DefaultWrapSampler, Texture2DParameter_e34b4ff04cbb4ec6b464e7b0efd7be9d_DefaultWrapSampler);
	float matReflectance;
	CalculateMatReflectance(In.TexCoords0, matReflectance, _DefaultWrapSampler, Texture2DParameter_d5f0bbd13eaa417daf2f7f12ee516b17_DefaultWrapSampler);
	float matRoughness;
	CalculateMatRoughness(In.TexCoords0, matRoughness, _DefaultWrapSampler, Texture2DParameter_d05006397acf4612938d1d4da6812f16_DefaultWrapSampler);
	GBufferData gBufferData;
	gBufferData.Emissive = float3(0.0f, 0.0f, 0.0f);
	gBufferData.ViewSpaceNormal = viewNormalNormalized;
	gBufferData.BaseColor = matBaseColor;
	gBufferData.FadeOpacity = uniforms._OpacityFade;
	gBufferData.Roughness = matRoughness;
	gBufferData.Reflectance = matReflectance;
	gBufferData.MetalMask = matMetalMask;
	gBufferData.FXEmissive = true;
	gBufferData.ShadingModel = 0;
	gBufferData.Custom = float4(0.0f, 0.0f, 0.0f, 0.0f);
	EncodeGBufferData(gBufferData, Out.Color0, Out.Color1, Out.Color2, Out.Color3);

	return Out;
}
