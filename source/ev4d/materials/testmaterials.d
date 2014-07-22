
module ev4d.materials.testmaterials;

import ev4d.rendersystem.material;
import ev4d.rendersystem.technique;

import derelict.opengl3.gl;
import gl3n.linalg;

class SimpleShader : Material
{
private:
	mat4 mworldMatrix;

public:
	this()
	{
		GLuint vshader = glCreateShader(GL_VERTEX_SHADER); // GL_FRAGMENT_SHADER
		glShaderSource(vshader, 1, r"".ptr, null);

		glCompileShader(vshader);

		GLuint p = glCreateProgram();

		glAttachShader(p, v);
		//glAttachShader(p,f);

		glLinkProgram(p);
		glUseProgram(p);

	}

	~this()
	{
		glDetachShader(p, v); // must be present probably
		glDeleteShader(0);
		glDeleteProgram(0);
	}

	@property pure int numberOfPasses() const { return 1; }
	@property int numberOfPasses(int n) const pure{ return 1; }

	@property mat4 worldMatrix() pure
	{
		return mworldMatrix;
	}

	@property mat4 worldMatrix(mat4 m)
	{
		return mworldMatrix = m;
	}

	@property GeneralTechnique[] getDependencies() const pure
	{
		return null;
	}

	void initMaterial()
	{

	}

	void initPass(int num)
	{

	}

	void renderPass(int num)
	{

	}

	void cleanUpPass(int num)
	{

	}

	void cleanUp()
	{
	}
}
