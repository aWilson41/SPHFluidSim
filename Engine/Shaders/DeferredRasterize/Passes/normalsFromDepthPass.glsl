#version 460
#define M_PI 3.1415926535897932384626433832795

layout(binding = 0) uniform sampler2D depthTex;

uniform float maxDepth;
uniform mat4x4 invProj;
uniform vec2 texelSize;

smooth in vec2 texCoord;

out vec3 fragNormal;

vec3 uvToEye(vec2 texCoord, float z)
{
	vec4 clipPos = vec4(texCoord * 2.0f - 1.0f, z, 1.0f);
	vec4 viewPos = invProj * clipPos;
	return viewPos.xyz / viewPos.w;
}

vec3 getEyePos(vec2 texCoord)
{
	return uvToEye(texCoord, texture(depthTex, texCoord).r);
}

void main()
{
    // read eye-space depth from texture
	float depth = texture(depthTex, texCoord).r;

	if (depth > maxDepth)
	{
		discard;
		return;
	}
	// Calculate eye-space position from depth
	vec3 posEye = uvToEye(texCoord, depth);

	// Calculate differences
	vec3 ddx = getEyePos(texCoord + vec2(texelSize.x, 0)) - posEye;
	vec3 ddx2 = posEye - getEyePos(texCoord + vec2(-texelSize.x, 0));
	if (abs(ddx.z) > abs(ddx2.z))
		ddx = ddx2;

	vec3 ddy = getEyePos(texCoord[0] + vec2(0, texelSize.y)) - posEye;
	vec3 ddy2 = posEye - getEyePos(texCoord + vec2(0, -texelSize.y));
	if (abs(ddy2.z) < abs(ddy.z))
		ddy = ddy2;

	// Calculate normal
	vec3 n = cross(ddx, ddy);
	fragNormal = normalize(n);
}