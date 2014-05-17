
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

		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		glVertexPointer(3, GL_FLOAT, 0, cast(const void*)(renderData.vertexes));
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, cast(const void*)(renderData.color));

		glColor4ubv(renderData.color.ptr);

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
}
