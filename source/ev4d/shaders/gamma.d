module ev4d.shaders.gamma;


const string pixelShaderFunctions = 
"
float gamma = 1/2.2; // in [2, 2.4]

float gammaCorrection(float light)
{
	return pow(light, gamma);
}

//vec3 color = lightingModel( … );
//FragColor = vec4( pow( color, vec3(1.0/Gamma) ), 1.0 );
";
