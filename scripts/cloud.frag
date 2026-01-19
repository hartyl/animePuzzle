varying vec2 texCoord;
varying vec3 cameraForward;
const float mul = 7/8.1;
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
	// vec4 texcolor = Texel(tex, vec2(max(texCoord.x,texCoord.y),min(texCoord.x,texCoord.y))*2);
	vec4 texcolor = Texel(tex, texCoord*mul);
	//if (texcolor.x < .20) discard;
	//if (texCoord.x*texCoord.x+texCoord.y*texCoord.y > 1) discard;
	//x=(1-x)*100;
	return (texCoord.y*2-1.1< texcolor.x*cameraForward.z*3 ? vec4(.5,.5,.5,1) : vec4(1));
}
