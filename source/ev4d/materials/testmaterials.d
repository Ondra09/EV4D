
module ev4d.materials.testmaterials;

import ev4d.rendersystem.material;
import ev4d.rendersystem.technique;

import derelict.opengl3.gl;
import gl3n.linalg;
import ev4d.io.model;
long offsetof = GameVertex_.nx.offsetof;
class SimpleShader(RenderData) : Material
{
private:
	GLuint program;
	GLuint vshader;
	GLuint fshader;

	RenderData* renderData;

	// shader uniforms
	GLint modelMatrix_u;
	GLint viewMatrix_u;
	GLint projectionMatrix_u;

	GLint customC;

	//
	
	VBO vbo;

public:
	this()
	{
		import std.string: toStringz;
		vshader = glCreateShader(GL_VERTEX_SHADER);
		fshader = glCreateShader(GL_FRAGMENT_SHADER);

		immutable(char)* vss = (r"
			uniform mat4 modelMatrix;
			uniform mat4 viewMatrix;
			uniform mat4 projectionMatrix;

			void main()
			{
				//gl_Position    = gl_ProjectionMatrix * gl_ModelViewMatrix * modelViewMatrix * gl_Vertex;

				gl_Position    = projectionMatrix * viewMatrix * modelMatrix * gl_Vertex;
				gl_FrontColor  = gl_Color;
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

		glShaderSource(vshader, 1, &vss, null);
		glShaderSource(fshader, 1, &fss, null);

		glCompileShader(vshader);
		glCompileShader(fshader);

		printInfoLog!"shader"(vshader);
		printInfoLog!"shader"(fshader);

		program = glCreateProgram();

		glAttachShader(program, vshader);
		glAttachShader(program, fshader);

		glLinkProgram(program);

		printInfoLog!"program"(program);

		modelMatrix_u = glGetUniformLocation(program, "modelMatrix");
		viewMatrix_u = glGetUniformLocation(program, "viewMatrix");
		projectionMatrix_u = glGetUniformLocation(program, "projectionMatrix");
		
		customC = glGetUniformLocation(program, "customC");
		
		assert(modelMatrix_u != -1);
		assert(customC != -1);
    	
    	testImport(vbo);
	}

	~this()
	{
		glDetachShader(program, vshader); // must be present probably
		glDeleteShader(0);
		glDeleteProgram(0);
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
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		//glVertexPointer(3, GL_FLOAT, 0, cast(const void*)(renderData.vertexes));
		//glColorPointer(4, GL_UNSIGNED_BYTE, 0, cast(const void*)(renderData.color));

		//glVertexPointer(3, GL_FLOAT, GameVertex_.sizeof, null);
		setVBOVertexPointers!(GameVertex_)();

		glColor4ubv(renderData.color.ptr);

		//glPushMatrix();

		//glMultMatrixf(mworldMatrix.value_ptr);
		glUseProgram(program);

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
		import std.stdio;

		
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo.idxIDs[0]);
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

		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
	}

	override void bindData(void* data) pure nothrow
	{
		renderData = cast(RenderData*)data;
	}
}
