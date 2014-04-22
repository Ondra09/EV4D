
module ev4d.rendersystem.material;
// todo switch to gl2 or gl3
import derelict.opengl3.gl;

import std.stdio;

interface Material
{
	@property int numberOfPasses();
	@property int numberOfPasses(int n);

	void initMaterial();

	void initPass(int num);

	void renderPass(int num);

	void cleanUpPass(int num);

	void cleanUp();
}

class SimpleMaterial(Renderdata): Material
{
private:
	int passes = 1;
public:
	// TODO : struct vs class make it possible to accept both
	Renderdata renderData;

	this()
	{
	}

	@property int numberOfPasses(){ return passes; }
	@property int numberOfPasses(int n){ return passes = n; }

	void bindData(Renderdata data)
	{
		renderData = data;
	}

	void initMaterial()
	{ 
		glColor3b(1, 0, 1); 
	}

	void initPass(int num){ }

	void renderPass(int num)
	{ 
		if (renderData is null)
			return;

		glBegin(GL_POINTS);

			glVertex3fv(renderData.vertexes.ptr);
			//glVertex3f(renderdata.vertexes[0], renderdata.vertexes[1], renderdata.vertexes[2]);

		glEnd();
	}

	void cleanUpPass(int num)
	{
		
	}

	void cleanUp()
	{
	}
}
