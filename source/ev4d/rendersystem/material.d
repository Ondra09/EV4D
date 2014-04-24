
module ev4d.rendersystem.material;
// todo switch to gl2 or gl3
import derelict.opengl3.gl;

import std.stdio;

interface Material
{
	@property int numberOfPasses();
	@property int numberOfPasses(int n);

	// TODO : Object or void* decide what better
	void bindData(Object material);

	void initMaterial();

	void initPass(int num);

	void renderPass(int num);

	void cleanUpPass(int num);

	void cleanUp();
}

class SimpleMaterial(RenderData): Material
{
private:
	int passes = 1;
public:
	// TODO : struct vs class make it possible to accept both
	RenderData renderData;

	this()
	{
	}

	@property int numberOfPasses(){ return passes; }
	@property int numberOfPasses(int n){ return passes = n; }

	override void bindData(Object data)
	{
		renderData = cast(RenderData)data;
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