
module ev4d.rendersystem.testmaterials;

import ev4d.rendersystem.material;
import ev4d.rendersystem.technique;

import derelict.opengl3.gl;
import gl3n.linalg;

import ev4d.io.texture;


class SimpleShader(BindVertex) : Material
{
package:
	// shader uniforms
	GLint modelMatrix_u;
	GLint viewMatrix_u;
	GLint projectionMatrix_u;

	GLint customC;

	//
	int tangentsAttribID;

public:
	this()
	{
		import std.string: toStringz;

		immutable(char)* vss = (r"
			uniform mat4 modelMatrix;
			uniform mat4 viewMatrix;
			uniform mat4 projectionMatrix;

			attribute vec3 vTangent;

			void main()
			{
				//gl_Position    = gl_ProjectionMatrix * gl_ModelViewMatrix * modelViewMatrix * gl_Vertex;

				gl_Position    = projectionMatrix * viewMatrix * modelMatrix * gl_Vertex;
				//gl_FrontColor  = gl_Color;
				gl_FrontColor  = vec4(vTangent, 1.0);
				gl_TexCoord[0] = gl_MultiTexCoord0;
			}
			".toStringz());

		immutable(char)* fss = (r"
			uniform vec4 customC;
			void main()
			{
				gl_FragColor = gl_Color * customC;
				//gl_FragColor = vec4(1,1,1,1);
			}
			".toStringz());

		createAndBindShader20(shader.program, shader.vshader, shader.fshader, vss, fss);

		GLuint[] locations;

		locations = obtainLocations20!"uniforms"(shader.program, ["modelMatrix", "viewMatrix", "projectionMatrix", "customC"]);

		modelMatrix_u = locations[0];
		viewMatrix_u = locations[1];
		projectionMatrix_u = locations[2];
		customC = locations[3];

		locations = obtainLocations20!("attributes")(shader.program,["vTangent"]);

		tangentsAttribID = -1;
		tangentsAttribID = locations[0];

		obtainLocations20!("attribues","vTangent", tangentsAttribID)(shader.program);
	}

	~this()
	{
		destroyShader20(shader.program, shader.vshader, shader.fshader);
	}


	override @property GeneralTechnique[] getDependencies() const pure nothrow
	{
		return null;
	}

	override void initMaterial()
	{ 
		//glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
		glDisable(GL_CULL_FACE);

		glBindBuffer(GL_ARRAY_BUFFER, vbo.vboIDs[0]);
		
		setVBOVertexPointers20!(BindVertex)();
		bindVertexAttrib20!(BindVertex, "tx")(tangentsAttribID);

		//glColor4ubv(renderData.color.ptr);

		//glPushMatrix();

		//glMultMatrixf(mworldMatrix.value_ptr);
		glUseProgram(shader.program);

		glUniformMatrix4fv(modelMatrix_u, 1, GL_FALSE, worldMatrix.value_ptr);
		glUniformMatrix4fv(viewMatrix_u, 1, GL_FALSE, viewMatrix.value_ptr);
		glUniformMatrix4fv(projectionMatrix_u, 1, GL_FALSE, projectionMatrix.value_ptr);

		//
		glUniform4f(customC, 1, 0, 1, 1);
	}

	override void initPass(int num)
	{
	}

	override void renderPass(int num)
	{ 
		
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo.idxIDs[0]); // remove this bind pbly
		glDrawElements(GL_TRIANGLES, 894, GL_UNSIGNED_INT, null);

		/*
		if (renderData is null)
			return;

		if (!(renderData.indices is null))
		{
			glDrawElements(GL_TRIANGLES, renderData.indicesCount, GL_UNSIGNED_BYTE, cast(const void*)(renderData.indices));
		}else
		{
			glDrawArrays(GL_TRIANGLES, 0, 8);
		}*/
	}

	override void cleanUpPass(int num)
	{
	}

	override void cleanUp()
	{
		//glPopMatrix();

		cleanUpVBOPointers20!(BindVertex)();

		glDisableVertexAttribArray(tangentsAttribID);
	}
}

class ShipMaterial(BindVertex) : Material
{
private:
package:
	// shader uniforms
	
	GLint modelViewMatrix_u;
	GLint modelViewProjectionMatrix_u;
	GLint normalMatrix_u;

	GLint tangent_a;

	// tex's uniforms
	GLint texColor_u;
	GLint texNormal_u;
	GLint texIllum_u;
	GLint texSpecular_u;

	// tex's id
	GLuint texColor;
	GLuint texNormal;
	GLuint texIllum;
	GLuint texSpecular;
protected:
public:
	this()
	{
		import std.string: toStringz;

		immutable(char)* vss = (r"
			// Eastern Wolf @ 2014
			//uniform mat4 mvpMatrix;

			uniform mat4 modelViewMatrix;
			uniform mat4 modelViewProjectionMatrix;
			uniform mat4 normalMatrix;
			
			attribute vec3 tangent;


			varying vec4 diffuse, ambient;

			varying vec3 halfVec;
			varying vec3 lightVec;
			varying vec3 eyeVec;

			struct PointLight 
			{ 
			   vec3 vColor; // Color of that point light
			   vec3 vPosition; 
			    
			   float fAmbient; 

			   float fConstantAtt; 
			   float fLinearAtt; 
			   float fExpAtt; 
			}; 

			void main()
			{
				vec3 normal;
				
				gl_Position    = modelViewProjectionMatrix * gl_Vertex;
				gl_FrontColor  = gl_Color;
				gl_TexCoord[0] = gl_MultiTexCoord0;

				diffuse = gl_FrontMaterial.diffuse * gl_LightSource[0].diffuse;
			    ambient = gl_FrontMaterial.ambient * gl_LightSource[0].ambient;
			    ambient += gl_LightModel.ambient * gl_FrontMaterial.ambient;

				// gl_NormalMatrix - 3x3 Matrix representing the inverse transpose model-view matrix
				normal  =	normalize(normalMatrix * vec4(gl_Normal, 1.0)).xyz;

				vec3 vertexPosition = vec3(modelViewMatrix *  gl_Vertex);
				vertexPosition /= (modelViewMatrix *  gl_Vertex).w;

				vec3 t;
				vec3 b;
				vec3 n = normal;

				t = tangent;
				b = normalize(cross(n, t));

				///////////////////////////////////
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
				eyeVec = normalize (v);
				// or use -reflect();
				vec3 halfVector = normalize(-vertexPosition + lightDir);
				v.x = dot (halfVector, t);
				v.y = dot (halfVector, b);
				v.z = dot (halfVector, n);

				halfVec = v ; 
			}
			".toStringz());

		immutable(char)* fss = (r"
			// Eeastern Wolf @ 2014

			// 'time' contains seconds since the program was linked.
			uniform float time;
			uniform sampler2D texColor;
			uniform sampler2D texNormal;
			uniform sampler2D texIllum;
			uniform sampler2D texSpecular;

			varying vec4 diffuse,ambient;

			varying vec3 normal, halfVec;
			varying vec3 lightVec;
			varying vec3 eyeVec;

			const float bumpMagnitude = 2.0;
			// return normalized vector
			vec3 compute_bump_normal()
			{
				vec4 bump = texture2D(texNormal, gl_TexCoord[0].st);

				vec3 normalTex;
				normalTex.x = dFdx(bump.r)*bumpMagnitude;
				normalTex.y = dFdy(bump.r)*bumpMagnitude;

				normalTex.z = sqrt(1.0 - normalTex.x*normalTex.x - normalTex.y * normalTex.y);

				return normalTex;
			}

			vec3 read_normal_map()
			{
				return 2.0*texture2D(texNormal, gl_TexCoord[0].st).xyz - 1.0;
			}

			void main()
			{
				//gl_FragColor = gl_Color;
				vec4 colorTex = texture2D(texColor, gl_TexCoord[0].st);
				vec4 illumTex = texture2D(texIllum, gl_TexCoord[0].st);
				vec4 specularTex = texture2D(texSpecular, gl_TexCoord[0].st);
			//gl_FragColor = colorTex;texture2D(texNormal, gl_TexCoord[0].st);
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
				
				//gl_FragColor = texture2D(texNormal, gl_TexCoord[0].st);
			}

			".toStringz());

		createAndBindShader20(shader.program, shader.vshader, shader.fshader, vss, fss);

		GLuint[] locations;

		locations = obtainLocations20!"uniforms"(shader.program,["modelViewMatrix",
																 "modelViewProjectionMatrix", "normalMatrix"]);

		modelViewMatrix_u = locations[0];
		modelViewProjectionMatrix_u = locations[1];
		normalMatrix_u = locations[2];
		

		obtainLocations20!("attribues", "tangent", tangent_a)(shader.program);

		locations = obtainLocations20!"uniforms"(shader.program,["texColor", "texNormal",
																 "texIllum", "texSpecular"]);

		texColor_u = locations[0];
		texNormal_u = locations[1];
		texIllum_u = locations[2];
		texSpecular_u = locations[3];

		texColor = loadImage("objects/work/Space Frigate 6/space_frigate_6/space_frigate_6_color.png");
		texNormal = loadImage("objects/work/Space Frigate 6/space_frigate_6/space_frigate_6 NRM.png");
		texIllum = loadImage("objects/work/Space Frigate 6/space_frigate_6/space_frigate_6_illumination.png");
		texSpecular = loadImage("objects/work/Space Frigate 6/space_frigate_6/space_frigate_6_specular.png");
	}

	~this()
	{
		destroyShader20(shader.program, shader.vshader, shader.fshader);

		(texColor) = -1;
		(texNormal) = -1;
		(texIllum) = -1;
		(texSpecular) = -1;

		deleteTexture("objects/work/Space Frigate 6/space_frigate_6/space_frigate_6_color.png");
		deleteTexture("objects/work/Space Frigate 6/space_frigate_6/space_frigate_6 NRM.png");
		deleteTexture("objects/work/Space Frigate 6/space_frigate_6/space_frigate_6_illumination.png");
		deleteTexture("objects/work/Space Frigate 6/space_frigate_6/space_frigate_6_specular.png");
	}

	override @property GeneralTechnique[] getDependencies() const pure nothrow
	{
		return null;
	}

	override void initMaterial()
	{ 
		//glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
		glDisable(GL_CULL_FACE);

		glBindBuffer(GL_ARRAY_BUFFER, vbo.vboIDs[0]);
		
		setVBOVertexPointers20!(BindVertex)();
		bindVertexAttrib20!(BindVertex, "tx")(tangent_a);

		//glColor4ubv(renderData.color.ptr);

		//glMultMatrixf(mworldMatrix.value_ptr);
		glUseProgram(shader.program);

		mat4 modelViewMatrix = worldMatrix * viewMatrix;
		mat4 modelViewProjectionMatrix = worldMatrix * viewMatrix * projectionMatrix;

		mat4 normalMatrix = modelViewMatrix.inverse();

		glUniformMatrix4fv(modelViewMatrix_u, 1, GL_FALSE, modelViewMatrix.value_ptr);
		glUniformMatrix4fv(modelViewProjectionMatrix_u, 1, GL_FALSE, modelViewProjectionMatrix.value_ptr);
		glUniformMatrix4fv(normalMatrix_u, 1, GL_FALSE, viewMatrix.value_ptr);

		//
		//glUniform4f(customC, 1, 0, 1, 1);
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, texColor);
		glUniform1i(texColor_u, 0);

		glActiveTexture(GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_2D, texNormal);
		glUniform1i(texNormal_u, 1);

		glActiveTexture(GL_TEXTURE2);
		glBindTexture(GL_TEXTURE_2D, texIllum);
		glUniform1i(texIllum_u, 2);

		glActiveTexture(GL_TEXTURE3);
		glBindTexture(GL_TEXTURE_2D, texSpecular);
		glUniform1i(texSpecular_u, 3);
		
	}

	override void initPass(int num)
	{
	}

	override void renderPass(int num)
	{ 
		
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo.idxIDs[0]); // remove this bind pbly
		glDrawElements(GL_TRIANGLES, 894, GL_UNSIGNED_INT, null);
	}

	override void cleanUpPass(int num)
	{
	}

	override void cleanUp()
	{

		cleanUpVBOPointers20!(BindVertex)();

		glDisableVertexAttribArray(tangent_a);
	}
}
