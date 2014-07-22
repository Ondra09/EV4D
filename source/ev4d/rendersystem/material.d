
module ev4d.rendersystem.material;

import ev4d.rendersystem.technique;

// todo switch to gl2 or gl3
import derelict.opengl3.gl;
import gl3n.linalg;

interface Material
{
	@property int numberOfPasses() pure;
	@property int numberOfPasses(int n);

	@property mat4 worldMatrix() pure;
	@property mat4 worldMatrix(mat4 m);

	@property GeneralTechnique[] getDependencies();

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
	RenderData* renderData;
	GeneralTechnique techniquesDep[];

	this()
	{
	}

	@property int numberOfPasses(){ return passes; }
	@property int numberOfPasses(int n){ return passes = n; }

	@property mat4 worldMatrix(){ return wMatrix; }
	@property mat4 worldMatrix(mat4 m){ m.transpose(); return wMatrix = m; }

	@property GeneralTechnique[] getDependencies(){ return techniquesDep; }

	void bindData(RenderData* data)
	{
		renderData = data;
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

		glMultMatrixf(wMatrix.value_ptr);
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
}
