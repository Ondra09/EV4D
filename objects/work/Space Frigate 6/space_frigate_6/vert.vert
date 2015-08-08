// Eastern Wolf @ 2014
//uniform mat4 mvpMatrix;


varying vec4 diffuse, ambient;

varying vec3 halfVec;
varying vec3 lightVec;
//varying vec3 eyeVec;


//attribute vec3 vTangent;

void main()
{
	vec3 normal;
	gl_Position    = gl_ModelViewProjectionMatrix * gl_Vertex;
	gl_FrontColor  = gl_Color;
	gl_TexCoord[0] = gl_MultiTexCoord0;

	diffuse = gl_FrontMaterial.diffuse * gl_LightSource[0].diffuse;
    ambient = gl_FrontMaterial.ambient * gl_LightSource[0].ambient;
    ambient += gl_LightModel.ambient * gl_FrontMaterial.ambient;

	// gl_NormalMatrix - 3x3 Matrix representing the inverse transpose model-view matrix
	normal =	 normalize(gl_NormalMatrix * gl_Normal);

	vec3 vertexPosition = vec3(gl_ModelViewMatrix *  gl_Vertex);
	vertexPosition /= (gl_ModelViewMatrix *  gl_Vertex).w;

	vec3 t;
	vec3 b;
	vec3 n = normal;

	////////// remove ///////
	if (n.y > 0.9)
	{
		b = normalize(cross(n,  vec3(n.x+0.5, n.y, n.z)));
		t = normalize(cross(b, n));
	}
	else
	{
		t = normalize(cross(vec3(n.x, n.y + 0.9, n.z), n));
		b = normalize(cross(n, t));
	}
	////////// remove ///////

	vec3 lightDir = normalize(gl_LightSource[0].position.xyz - vertexPosition);
	// transform light and half angle vectors by tangent basis
	vec3 v;
	v.x = dot (lightDir, t);
	v.y = dot (lightDir, b);
	v.z = dot (lightDir, n);
	lightVec = normalize (v);

	v.x = dot (-vertexPosition, t); // eye - vertex .. eye = [0,0,0]
	v.y = dot (-vertexPosition, b);
	v.z = dot (-vertexPosition, n);
	//eyeVec = normalize (v);

	vec3 halfVector = normalize(-vertexPosition + lightDir);
	v.x = dot (halfVector, t);
	v.y = dot (halfVector, b);
	v.z = dot (halfVector, n);

	halfVec = v ; 
}
