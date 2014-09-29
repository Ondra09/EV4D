
module ev4d.rendersystem.testmaterials;

import ev4d.rendersystem.material;
import ev4d.rendersystem.technique;

import derelict.opengl3.gl;
import gl3n.linalg;


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
	//

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

			varying vec3 normal, halfVec;
			varying vec3 lightVec;
			varying vec3 eyeVec;


			void main()
			{
				gl_Position    = modelViewProjectionMatrix * gl_Vertex;
				gl_FrontColor  = gl_Color;
				gl_TexCoord[0] = gl_MultiTexCoord0;

				diffuse = gl_FrontMaterial.diffuse * gl_LightSource[0].diffuse;
			    ambient = gl_FrontMaterial.ambient * gl_LightSource[0].ambient;
			    ambient += gl_LightModel.ambient * gl_FrontMaterial.ambient;

				// gl_NormalMatrix - 3x3 Matrix representing the inverse transpose model-view matrix
				normal =	 normalize(normalMatrix * gl_Normal);

				vec3 vertexPosition = vec3(modelViewMatrix *  gl_Vertex);
				vertexPosition /= (modelViewMatrix *  gl_Vertex).w;

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
				eyeVec = normalize (v);

				vec3 halfVector = normalize(-vertexPosition + lightDir);
				v.x = dot (halfVector, t);
				v.y = dot (halfVector, b);
				v.z = dot (halfVector, n);

				halfVec = v ; 
			}
			".toStringz());

		immutable(char)* fss = (r"
			
			".toStringz());

		createAndBindShader20(shader.program, shader.vshader, shader.fshader, vss, fss);

		GLuint[] locations;

		locations = obtainLocations20!"uniforms"(shader.program,["modelViewMatrix",
																 "modelViewProjectionMatrix", "normalMatrix"]);

		modelViewMatrix_u = locations[0];
		modelViewProjectionMatrix_u = locations[1];
		normalMatrix_u = locations[2];
		

		obtainLocations20!("attribues", "tangent", tangent_a)(shader.program);
	}

	~this()
	{
		destroyShader20(shader.program, shader.vshader, shader.fshader);
	}
}
