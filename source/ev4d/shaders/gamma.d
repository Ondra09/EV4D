module ev4d.shaders.gamma;


immutable string pixelShaderFunctions = 
"
float gamma = 1/2.2; // in [2, 2.4]

float gammaCorrection(float light)
{
	return pow(light, gamma);
}

//vec3 color = lightingModel( … );
//FragColor = vec4( pow( color, vec3(1.0/Gamma) ), 1.0 );
";

immutable string fogPixelShaderFunction = 
"
float linearFog(float dst, float maxDst, float minDst)
{
	return (maxDst - dst) / (maxDst - minDst);
}

float expFog(float dst, float density)
{
	return exp(-pow(density*dist, 2.0)); // pow not necessary
}

vec3 computeFog(float dst, float density, vec4 shadeColor)
{	
	fogFactor = expFog(dst, density);

	fogFactor = clamp( fogFactor, 0.0, 1.0 );

	vec3 color = mix( fog.color, shadeColor.xyz, fogFactor );

	return color;
}
";
