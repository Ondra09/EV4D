
module ev4d.rendersystem.material;

import ev4d.rendersystem.technique;

// todo switch to gl2 or gl3
import derelict.opengl3.gl;
import gl3n.linalg;

struct VBO
{
	GLuint[] vboIDs;
	uint[] idxIDs;
}

void bindVertexAttrib20(Vertex, string field)(int attribLocation, bool normalized = false)
{
	static if (__traits(hasMember, Vertex, field)) // tangents
	{
		glEnableVertexAttribArray( attribLocation );

		with (Vertex)
		{
		glVertexAttribPointer(	attribLocation,
								__traits(getAttributes, mixin(field))[0],
								__traits(getAttributes, mixin(field))[1],
								normalized,	// normalized
								Vertex.sizeof, cast(const void*)(mixin(field).offsetof) );
		}
	}
}

// binds buid in opengl variables
// you should bind attrib yourself
void setVBOVertexPointers20(Vertex)()
{
	static if (__traits(hasMember, Vertex, "x"))
	{

		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(__traits(getAttributes, Vertex.x)[0], 
						__traits(getAttributes, Vertex.x)[1], 
						Vertex.sizeof, cast(void*)(Vertex.x.offsetof));
	}

	static if (__traits(hasMember, Vertex, "cx"))
	{
		glEnableClientState(GL_COLOR_ARRAY);
		glColorPointer(	__traits(getAttributes, Vertex.cx)[0], 
						__traits(getAttributes, Vertex.cx)[1], 
						Vertex.sizeof, cast(const void*)(Vertex.cx.offsetof) );
	}

	static if (__traits(hasMember, Vertex, "nx"))
	{
		glEnableClientState(GL_NORMAL_ARRAY);
		glNormalPointer( 
						__traits(getAttributes, Vertex.nx)[1], 
						Vertex.sizeof, cast(const void*)(Vertex.nx.offsetof) );
	}

	static if (__traits(hasMember, Vertex, "u"))
	{
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glTexCoordPointer(	__traits(getAttributes, Vertex.u)[0],
							__traits(getAttributes, Vertex.u)[1], 
							Vertex.sizeof, cast(const void*)(Vertex.u.offsetof) );
	}
}

//
void cleanUpVBOPointers20(Vertex)()
{
	static if (__traits(hasMember, Vertex, "x"))
	{
		glDisableClientState(GL_VERTEX_ARRAY);
	}

	static if (__traits(hasMember, Vertex, "cx"))
	{
		glDisableClientState(GL_COLOR_ARRAY);
	}

	static if (__traits(hasMember, Vertex, "nx"))
	{
		glDisableClientState(GL_NORMAL_ARRAY);
	}

	static if (__traits(hasMember, Vertex, "u"))
	{
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
}

// TODO : write similar functions like obove for vertexattrib binding

/**
	All matrices are expected in column mayor and right format for camera. (inversion)
*/
class Material
{
private:
	mat4 mworldMatrix = mat4.identity();
	mat4 mviewMatrix = mat4.identity();

	mat4 mprojectionMatrix = void; //!!!

	int passes = 1;
protected:
	VBO* vbo;
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

	alias modelMatrix = worldMatrix;

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

	void bindVBO(VBO* nVbo)
	{
		vbo = nVbo;
	}


	abstract @property GeneralTechnique[] getDependencies();

	abstract void initMaterial();

	abstract void initPass(int num);

	abstract void renderPass(int num);

	abstract void cleanUpPass(int num);

	abstract void cleanUp();
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

	void bindData(void* data)
	{
		renderData = cast(RenderData*)data;
	}

	override void initMaterial()
	{ 
		//glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
		if (renderData is null)
			return;
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
    	import core.memory;

        char* infoLog = cast(char*) GC.malloc(infologLength);
        scope(exit) GC.free(infoLog);
        
        static if(type == "shader")
        {
        	glGetShaderInfoLog(obj, infologLength, &charsWritten, infoLog);
        	write("Shader: ");
        }else if (type == "program")
        {
        	glGetProgramInfoLog(obj, infologLength, &charsWritten, infoLog);
        	write("Program: ");
        }
        write(file,":", line, " ");
		printf("%s", infoLog);
    }
}
