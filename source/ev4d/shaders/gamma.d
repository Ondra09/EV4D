module ev4d.shaders.gamma;


const string pixelShaderFunctions = 
"
float gamma = 1/2.2; // in [2, 2.4]

float gammaCorrection(float light)
{
	return pow(light, gamma);
}
";
