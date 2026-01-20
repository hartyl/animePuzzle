// written by groverbuger for g3d
// september 2021
// MIT license

// this vertex shader is what projects 3d vertices in models onto your 2d screen

varying vec3 texCoord;
varying vec3 cameraForward;
varying vec3 worldPosition;
#ifdef VERTEX
attribute vec4 InstancePosition;
uniform lowp mat4 projectionMatrix;
uniform mat3 viewMatrix;

uniform vec3 translation;

attribute vec3 VertexNormal;

varying vec3 viewPosition;
varying vec4 screenPosition;
uniform float size;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
	// worldPosition += vec4(vertexPosition.x,vertexPosition.y,vertexPosition.z,0);
	// float cosPitch = sin(cameraRight.z);
	// vec3 cameraUp = vec3(cameraRight.y*cosPitch,-cameraRight.x*cosPitch,-cos(cameraRight.z));
	// vec3 cameraForward = -cross(vec3(cameraRight.xy,0), cameraUp);
	vec3 pos = InstancePosition.xyz + translation;
	pos = (pos.z<-50?vec3(pos.xy,pos.z+100):pos);
	cameraForward = normalize(pos);
	vec3 cameraRight = normalize(cross(cameraForward, vec3(0,0,1)));
	vec3 cameraUp = cross(cameraForward,cameraRight);
	worldPosition = cameraUp * vertexPosition.y;
	worldPosition += cameraRight * vertexPosition.x;
	// worldPosition.xy *= worldPosition.z + 2;
	// worldPosition = viewMatrix * worldPosition;
	worldPosition -= cameraForward * vertexPosition.z;
	viewPosition = viewMatrix * (pos + worldPosition * (InstancePosition.w+1)*size);
	// viewPosition.xy -= vertexPosition.xy * (InstancePosition.w+1);
	screenPosition = projectionMatrix * vec4(viewPosition,1);
	// texCoord = worldPosition.xy;
	texCoord.xy = (vertexPosition.xy)*7/8.1;
	texCoord.z = dot(worldPosition,viewMatrix*vec3(0,1,1));

	// save some data from this vertex for use in fragment shaders
	// vertexNormal = VertexNormal;
	// vertexColor = VertexColor;

	// for some reason models are flipped vertically when rendering to a canvas
	// so we need to detect when this is being rendered to a canvas, and flip it back

	return screenPosition;
}
#endif
#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
	float texcolor = Texel(tex, texCoord.xy).r;
	return (dot(worldPosition-cameraForward*texcolor,vec3(0,-1,1))<0 ? vec4(.4,.5,.6,1) : vec4(.8,.9,1,1));
}
#endif
