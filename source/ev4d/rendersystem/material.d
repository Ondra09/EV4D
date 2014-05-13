
module ev4d.rendersystem.material;

// todo switch to gl2 or gl3
import derelict.opengl3.gl;
import gl3n.linalg;

import std.stdio;

interface Material
{
	@property int numberOfPasses();
	@property int numberOfPasses(int n);

	@property mat4 worldMatrix();
	@property mat4 worldMatrix(mat4 m);

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
	mat4 wMatrix = mat4.identity();
public:
	// TODO : struct vs class make it possible to accept both
	RenderData renderData;

	this()
	{
	}

	@property int numberOfPasses(){ return passes; }
	@property int numberOfPasses(int n){ return passes = n; }

	@property mat4 worldMatrix(){ return wMatrix; }
	@property mat4 worldMatrix(mat4 m){ m.transpose(); return wMatrix = m; }

	override void bindData(Object data)
	{
		renderData = cast(RenderData)data;
	}

	void initMaterial()
	{ 
		glColor3b(1, 0, 1);
		glPushMatrix();
		
		glMultMatrixf(wMatrix.value_ptr);
	}

	void initPass(int num)
	{
	}

	void renderPass(int num)
	{ 
		if (renderData is null)
			return;

		//glBegin(GL_POINTS);
		//	glVertex3fv(renderData.vertexes.ptr);
		//glEnd();

		glBegin(GL_QUADS);			
			glVertex4f(0.15f, 0.15f, 0, 1);
			glVertex4f(-0.15f, 0.15f, 0, 1);
			glVertex4f(-0.15f, -0.15f, 0, 1);
			glVertex4f(0.15f, -0.15f, 0, 1);			
		glEnd();
	}

	void cleanUpPass(int num)
	{
	}

	void cleanUp()
	{
		glPopMatrix();
	}
}
