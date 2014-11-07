
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

/**
	Material for ships.	
*/
class ShipMaterial(BindVertex) : Material
{
private:
package:
	// shader uniforms
	
	GLint modelViewMatrix_u = -1;
	GLint modelViewProjectionMatrix_u = -1;
	GLint normalMatrix_u = -1;

	GLint lightPositionsMatrix_u = -1;

	GLint tangent_a = -1;

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

			uniform mat4 modelViewMatrix;
			uniform mat4 modelViewProjectionMatrix;
			uniform mat4 normalMatrix;
			
			// in world coordinates
			uniform mat3 lightPositions;

			attribute vec3 tangent;

			varying vec4 diffuse, ambient;

			varying mat3 lightVecs;
			varying mat3 halfVecs;


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
				gl_Position    = modelViewProjectionMatrix * gl_Vertex;
				gl_FrontColor  = gl_Color;
				gl_TexCoord[0] = gl_MultiTexCoord0;

				diffuse = gl_FrontMaterial.diffuse * gl_LightSource[0].diffuse;
				diffuse = vec4(0.7, 0.7, 0.7, 1.0);
			    
			    ambient = gl_FrontMaterial.ambient * gl_LightSource[0].ambient;
			    ambient += gl_FrontMaterial.ambient * gl_LightModel.ambient;
				ambient = vec4(0.1, 0.1, 0.1, 1.0);

			    // gl_NormalMatrix - 3x3 Matrix representing the inverse transpose model-view matrix
				// mat4 normalMatrix = transpose(inverse(modelView));
				// OPTIM : 
				// if matrix contains only rotation or uniform scale than normalMatrix == modelViewMatrix;

				vec4 vertexPosition_w = modelViewMatrix *  gl_Vertex;
				vec3 vertexPosition = vertexPosition_w.xyz/vertexPosition_w.w;

				vec3 t = normalize(normalMatrix * vec4(tangent, 0.0)).xyz;
				vec3 b;
				vec3 n = normalize(normalMatrix * vec4(gl_Normal, 0.0)).xyz;

				b = normalize(cross(n, t));

				mat3 tangentMatrix = mat3(
										t.x, b.x, n.x, // first column
										t.y, b.y, n.y, // second column
										t.z, b.z, n.z // third column
										);

				mat3 vertexPosMat = mat3(vertexPosition, vertexPosition, vertexPosition);

				mat3 lDirs = lightPositions - vertexPosMat;

				// transform light and half angle vectors by tangent basis
				lightVecs = tangentMatrix * lDirs;
				halfVecs = tangentMatrix * (-vertexPosMat + lDirs);
			}
			".toStringz());

		immutable(char)* fss = (r"
			// Eastern Wolf @ 2014

			// 'time' contains seconds since the program was linked.
			uniform float time;
			uniform sampler2D texColor;
			uniform sampler2D texNormal;
			uniform sampler2D texIllum;
			uniform sampler2D texSpecular;

			varying vec4 diffuse, ambient;

			varying mat3 lightVecs;
			varying mat3 halfVecs;

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

			vec3 performLighting()
			{
				return vec3(1);
			}
			
			void main()
			{
				vec4 colorTex = texture2D(texColor, gl_TexCoord[0].st);
				vec4 illumTex = texture2D(texIllum, gl_TexCoord[0].st);
				vec4 specularTex = texture2D(texSpecular, gl_TexCoord[0].st);
			
				//vec3 normalTex = compute_bump_normal();
				vec3 normalTex = read_normal_map();

				//
				vec3 n, halfV;
			    float NdotHV;
			 
			    /* The ambient term will always be present */
			    // emmisive term ommited
			    vec4 color = diffuse * colorTex * ambient; // ambient term
			    
				n = normalTex;
				//vec4 testColor = vec4(0,0,0,1);

				// BUG: normals are in wrong dirrection on half of the model
				for (int i = 0; i < 3; i++)
				{
					vec3 lightVector = normalize(lightVecs[i]);

					float NdotL = max(dot(n, lightVector), 0.0);

					if (NdotL > 0.0)
					{
				        color += diffuse * NdotL * colorTex;

				        halfV = normalize(halfVecs[i]);

				        NdotHV = clamp(dot(n, halfV),0.0, 1.0);
					
						float shininess = specularTex.r * 255.0;

				        color += pow(NdotHV, 90.0);
				        		//gl_FrontMaterial.specular *
				                //gl_LightSource[0].specular *
				                pow(NdotHV, 90.0);
				                //pow(NdotHV, gl_FrontMaterial.shininess);
								//pow(NdotHV, 128.0) * specularTex; // specular omited

						//testColor = pow(NdotHV, 80.0) * specularTex;
				    }

					//testColor[i] = max(dot(n, lightVector), 0.0);
				}


			    // hacked gamma correction .. looks good
			    color.x = pow(color.x, 1.0/2.2);
			    color.y = pow(color.y, 1.0/2.2);
			    color.z = pow(color.z, 1.0/2.2);
			    color.w = pow(color.w, 1.0/2.2);
			 
				gl_FragColor = color + illumTex;

				//gl_FragColor = testColor;

				/*vec3 diff = abs(lightVecs[0] - n)*2.0; // this is interesting effect

				diff = abs(lightVecs[1] - lightVec)*2.0;
				gl_FragColor = vec4(diff, 1 );*/
			}

			".toStringz());

		createAndBindShader20(shader.program, shader.vshader, shader.fshader, vss, fss);

		GLuint[] locations;

		locations = obtainLocations20!"uniforms"(shader.program,["modelViewMatrix",
																 "modelViewProjectionMatrix", "normalMatrix", "lightPositions"]);

		modelViewMatrix_u = locations[0];
		modelViewProjectionMatrix_u = locations[1];
		normalMatrix_u = locations[2];
		lightPositionsMatrix_u = locations[3];
		

		obtainLocations20!("attributes", "tangent", tangent_a)(shader.program);

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

		//lightPositionsMatrix_u = -1;

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
		normalMatrix.transpose();

		glUniformMatrix4fv(modelViewMatrix_u, 1, GL_FALSE, modelViewMatrix.value_ptr);
		glUniformMatrix4fv(modelViewProjectionMatrix_u, 1, GL_FALSE, modelViewProjectionMatrix.value_ptr);
		// GL_TRUE to have transpose matrix
		// mat4 normalMatrix = transpose(inverse(modelView));
		glUniformMatrix4fv(normalMatrix_u, 1, GL_FALSE, normalMatrix.value_ptr);

		/*import std.stdio;
		writeln("MM: ", modelViewMatrix);
		writeln("IM: ", normalMatrix);*/

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
	mat3 lights = mat3(	0, 1, 0, 	// first light
						1, 0, 0,  	// second light
						-1, 0, 0 );	// third light
	override void initPass(int num)
	{
		//lights = mat3(0, 0, 0, 0, 0, 0, 0, 0, 0);
		glUniformMatrix3fv(lightPositionsMatrix_u, 1, GL_FALSE, lights.value_ptr);
	}

	override void renderPass(int num)
	{ 

		//lights[0][1] += 0.1;

		////////////////////////////////////////////////////////////////////////////////	
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
