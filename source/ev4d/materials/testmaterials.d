
module ev4d.materials.testmaterials;

import ev4d.rendersystem.material;
import ev4d.rendersystem.technique;

import derelict.opengl3.gl;
import gl3n.linalg;

void printInfoLog(string type)(GLuint obj,  string file = __FILE__, int line = __LINE__)
{
	import std.stdio;

    int infologLength = 0;
    int charsWritten  = 0;
    static if(type == "shader")
    {
    	glGetShaderiv(obj, GL_INFO_LOG_LENGTH, &infologLength);
    }else if (type == "program")
    {
    	glGetProgramiv(obj, GL_INFO_LOG_LENGTH, &infologLength);
    }

    if (infologLength > 0)
    {
        auto infoLog = new char[infologLength];
        static if(type == "shader")
        {
        	glGetShaderInfoLog(obj, infologLength, &charsWritten, infoLog.ptr);
        	write("Shader: ");
        }else if (type == "program")
        {
        	glGetProgramInfoLog(obj, infologLength, &charsWritten, infoLog.ptr);
        	write("Program: ");
        }
        write(file,":", line, " ");
		write(infoLog);
    }
}

class SimpleShader(RenderData) : Material
{
private:
	mat4 mworldMatrix;

	GLuint program;
	GLuint vshader;
	GLuint fshader;

	RenderData* renderData;

	// shader uniforms
	GLint modelViewMatrix;
	GLint customC;
public:
	this()
	{
		import std.string: toStringz;
		vshader = glCreateShader(GL_VERTEX_SHADER);
		fshader = glCreateShader(GL_FRAGMENT_SHADER);

		immutable(char)* vss = (r"
			uniform mat4 modelViewMatrix;

			void main()
			{
				gl_Position    = gl_ProjectionMatrix * modelViewMatrix * gl_Vertex;
				gl_FrontColor  = gl_Color;
				gl_TexCoord[0] = gl_MultiTexCoord0;
			}
			".toStringz());

		immutable(char)* fss = (r"
			uniform vec4 customC;
			void main()
			{
				gl_FragColor = gl_Color * customC;
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

		modelViewMatrix = glGetUniformLocation(program, "modelViewMatrix");
		customC = glGetUniformLocation(program, "customC");
		//assert(modelViewMatrix != 0);
	}

	~this()
	{
		glDetachShader(program, vshader); // must be present probably
		glDeleteShader(0);
		glDeleteProgram(0);
	}

	@property pure int numberOfPasses() const { return 1; }
	@property int numberOfPasses(int n) const pure{ return 1; }

	@property mat4 worldMatrix() pure nothrow
	{
		return mworldMatrix;
	}

	@property mat4 worldMatrix(mat4 m)
	{
		m.transpose(); 
		return mworldMatrix = m;
	}

	@property GeneralTechnique[] getDependencies() const pure nothrow
	{
		return null;
	}

	void initMaterial()
	{ 
		//glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );

		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		glVertexPointer(3, GL_FLOAT, 0, cast(const void*)(renderData.vertexes));
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, cast(const void*)(renderData.color));

		glColor4ubv(renderData.color.ptr);

		glPushMatrix();

		glMultMatrixf(mworldMatrix.value_ptr);
		glUseProgram(program);
		glUniform4fv(modelViewMatrix, 1, GL_TRUE, mworldMatrix.value_ptr);
		glUniform4f(customC, 1, 0, 1, 1);
	}

	void initPass(int num)
	{
	}

	void renderPass(int num)
	{ 
		import std.stdio;

		if (renderData is null)
			return;

		if (!(renderData.indices is null))
		{
			glDrawElements(GL_TRIANGLES, renderData.indicesCount, GL_UNSIGNED_BYTE, cast(const void*)(renderData.indices));
		}else
		{
			glDrawArrays(GL_TRIANGLES, 0, 8);
		}
	}

	void cleanUpPass(int num)
	{
	}

	void cleanUp()
	{
		glPopMatrix();

		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
	}

	void bindData(void* data) pure nothrow
	{
		renderData = cast(RenderData*)data;
	}
}
