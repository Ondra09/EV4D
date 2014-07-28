
module ev4d.rendersystem.material;

import ev4d.rendersystem.technique;

// todo switch to gl2 or gl3
import derelict.opengl3.gl;
import gl3n.linalg;

class Material
{
private:
	mat4 mviewMatrix = mat4.identity();
	mat4 mworldMatrix = mat4.identity();

	mat4 mprojectionMatrix = void; //!!!

	int passes = 1;
public:
	@property int numberOfPasses() pure nothrow { return passes; }
	@property int numberOfPasses(int n) {return passes = n; }

	@property mat4 worldMatrix() pure nothrow
	{
		return mworldMatrix;
	}

	@property mat4 worldMatrix(mat4 m)
	{
		return mworldMatrix = m;
	}

	@property mat4 viewMatrix() pure nothrow
	{
		return mviewMatrix;
	}

	@property mat4 viewMatrix(mat4 m)
	{
		return mviewMatrix = m;
	}

	@property mat4 projectionMatrix() pure nothrow
	{
		return mprojectionMatrix;
	}

	@property mat4 projectionMatrix(mat4 m)
	{
		return mprojectionMatrix = m;
	}


	abstract @property GeneralTechnique[] getDependencies();

	abstract void initMaterial();

	abstract void initPass(int num);

	abstract void renderPass(int num);

	abstract void cleanUpPass(int num);

	abstract void cleanUp();
	abstract void bindData(void* data);
}

class SimpleMaterial(RenderData): Material
{
private:
	
public:
	// TODO : struct vs class make it possible to accept both
	RenderData* renderData;
	GeneralTechnique techniquesDep[];

	this()
	{
	}

	override @property GeneralTechnique[] getDependencies(){ return techniquesDep; }

	override void bindData(void* data)
	{
		renderData = cast(RenderData*)data;
	}

	override void initMaterial()
	{ 
		//glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );

		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		glVertexPointer(3, GL_FLOAT, 0, cast(const void*)(renderData.vertexes));
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, cast(const void*)(renderData.color));

		glColor4ubv(renderData.color.ptr);

		glPushMatrix();

		glMultMatrixf(worldMatrix.value_ptr);
	}

	override void initPass(int num)
	{
	}

	override void renderPass(int num)
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

	override void cleanUpPass(int num)
	{
	}

	override void cleanUp()
	{
		glPopMatrix();

		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
	}
}
