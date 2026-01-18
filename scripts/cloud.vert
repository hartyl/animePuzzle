#pragma language glsl3
#extension GL_EXT_gpu_shader4 : enable

noperspective varying vec2 texCoord;
attribute vec4 InstancePosition;
uniform lowp mat4 projectionMatrix;
uniform mat3 viewMatrix;

uniform vec3 translation;
uniform float time;

varying vec3 worldPosition;
varying vec3 viewPosition;
varying vec4 screenPosition;
varying vec3 cameraForward;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
	vec3 pos = vec3(InstancePosition.xy+InstancePosition.zw*time +translation.xy,0);

	ivec2 ipos = ivec2(pos.xy);
	pos.xy = vec2((ipos+2048) & 4095)-2048+(pos.xy-ipos);
	float l = length(pos.xy);
	pos.z = translation.z+100*(1-l/2048);
	cameraForward.z = pos.z/l;
	viewPosition = viewMatrix * pos;
	viewPosition.xy += vertexPosition.xy * 32;//*(1-l/2000*3);
	screenPosition = projectionMatrix *
		vec4(viewPosition,1);
	texCoord = (vertexPosition.xy+1.15)*.5;
	return screenPosition;
}
