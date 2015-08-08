// Eeastern Wolf @ 2014

// 'time' contains seconds since the program was linked.
uniform float time;
uniform sampler2D texColor;
uniform sampler2D texBump;
uniform sampler2D texIllum;
uniform sampler2D texSpecular;

varying vec4 diffuse,ambient;

varying vec3 normal, halfVec;
varying vec3 lightVec;
//varying vec3 eyeVec;

const float bumpMagnitude = 2.0;
// return normalized vector
vec3 compute_bump_normal()
{
	vec4 bump = texture2D(texBump, gl_TexCoord[0].st);

	vec3 normalTex;
	normalTex.x = dFdx(bump.r)*bumpMagnitude;
	normalTex.y = dFdy(bump.r)*bumpMagnitude;

	normalTex.z = sqrt(1.0 - normalTex.x*normalTex.x - normalTex.y * normalTex.y);

	return normalTex;
}

vec3 read_normal_map()
{
	return 2.0*texture2D(texBump, gl_TexCoord[0].st).xyz - 1.0;
}

void main()
{
	//gl_FragColor = gl_Color;
	vec4 colorTex = texture2D(texColor, gl_TexCoord[0].st);
	vec4 illumTex = texture2D(texIllum, gl_TexCoord[0].st);
	vec4 specularTex = texture2D(texSpecular, gl_TexCoord[0].st);
//gl_FragColor = colorTex;texture2D(texBump, gl_TexCoord[0].st);
//return;
	//vec3 normalTex = compute_bump_normal();
	vec3 normalTex = read_normal_map();
	//normalTex = vec3(0.0, 0.0, 1.0);


	//
	vec3 n, halfV, lightDir;
    float NdotL, NdotHV;
 
    lightDir = vec3(gl_LightSource[0].position);
 
    /* The ambient term will always be present */
    vec4 color = ambient * colorTex;
    
    // n = normalize(normal);
	n = normalTex;

	vec3 lightVector = normalize(lightVec);

    /* compute the dot product between normal and ldir */
 
    NdotL = max(dot(n, lightVector),0.0);

	
	if (NdotL > 0.0) 
	{
        color += diffuse * NdotL * colorTex;
        halfV = normalize(halfVec);

        NdotHV = clamp(dot(n, halfV),0.0, 1.0);
	
		float shininess = specularTex.r * 255.0;

        color += gl_FrontMaterial.specular *
                gl_LightSource[0].specular *
                //pow(NdotHV, gl_FrontMaterial.shininess);
				pow(NdotHV, shininess);
    }

 	// check if illumTex is computed correctly
 
	gl_FragColor = color + illumTex;

	//gl_FragColor = colorTex;
}
