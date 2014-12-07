
module ev4d.rendersystem.material;

import ev4d.rendersystem.technique;
import ev4d.rendersystem.lights;

// todo switch to gl2 or gl3
import derelict.opengl3.gl;
import gl3n.linalg;

struct VBO
{
	GLuint[] vboIDs;
	uint[] idxIDs;
}

/**
Generates OpenGL vertex buffers. Index and vertexbuffer;
*/
void genBuffers(ref VBO vbo, int num)
{
	vbo.vboIDs.reserve(num);
	vbo.vboIDs.length = num;

	vbo.idxIDs.reserve(num);
	vbo.idxIDs.length = num;

	//
	glGenBuffers(num, vbo.vboIDs.ptr);
	glGenBuffers(num, vbo.idxIDs.ptr);
}
/**
Deletes OpenGL vertex buffers.
*/
void delBuffers(ref VBO vbo)
{
	glDeleteBuffers(cast(int)vbo.vboIDs.length, vbo.vboIDs.ptr);
}

/**
Binds data array to apropriate bufferID
@param vboId vbo's id to bind the data
@param vArray array holding the data
@param target same as in glBufferData target.
@param usage same as in glBufferData usage.
*/
void bindBufferAndData(Vertex)(	GLuint vboId, Vertex[] vArray, 
								GLenum target = GL_ARRAY_BUFFER, GLenum usage = GL_STATIC_DRAW)
{
	glBindBuffer(target, vboId);
	glBufferData(target, Vertex.sizeof*vArray.length, vArray.ptr, usage);
	glBindBuffer(target, 0);
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

void createAndBindShader20( ref GLuint program,
							ref GLuint vshader,
							ref GLuint fshader,
							in immutable(char)* vss, in immutable(char) *fss)
{
	vshader = glCreateShader(GL_VERTEX_SHADER);
	fshader = glCreateShader(GL_FRAGMENT_SHADER);

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
}

void destroyShader20(in GLuint program, in GLuint vshader, in GLuint fshader)
{
	glDetachShader(program, vshader); // must be present probably
	glDetachShader(program, fshader);
	glDeleteShader(vshader);
	glDeleteShader(fshader);
	glDeleteProgram(program);
}

GLuint[] obtainLocations20(string type)(in GLuint program, in string[] names) nothrow
{
	GLuint[] retVal;

	retVal.length = names.length;
	foreach (int i, const string str; names)
	{
		import std.string: toStringz;
		GLuint unifLocat = -1;

		static if(type == "uniforms")
		{
			unifLocat = glGetUniformLocation(program, str.toStringz());
		}
		static if(type == "attributes")
		{
			unifLocat = glGetAttribLocation(program, str.toStringz());
		}

		assert(unifLocat != -1, "Invalid shader location.");
		retVal[i] = unifLocat;
	}

	return retVal;
}
/** To be able to use this function, class must use at least package protected
*	symbol.
* Examples:
* -----------------
* class A
* {
*	package:
*	GLUint vertex;
* }
* ...
* obtainLocations20("uniforms","vertexNameInShader", vertex)(shader.program);
* -----------------
*/
void obtainLocations20(string type, T...)(GLuint program)
//if(type=="uniforms" || type == "attributes")
{
	static assert((T.length % 2) == 0,
                  "Members must be specified as pairs.");
	
	import std.string: toStringz;

	foreach (i, const arg; T)
	{
		static if ( i % 2 == 1 ) // odd
		{
		}else // 
		{
			static assert (is (typeof(arg) == string),
                           "Member name " ~ arg.stringof ~
                           " is not a string.");

			T[i+1] = -1;

			static if(type == "uniforms")
			{
			T[i+1] = glGetUniformLocation(program, T[i].toStringz());
			}
			static if(type == "attributes")
			{
			T[i+1] = glGetAttribLocation(program, T[i].toStringz());
			}

			assert(T[i+1] != -1, "Invalid shader location.");
		}
	}
}

struct Shader20
{
	GLuint program;
	GLuint vshader;
	GLuint fshader;
}

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

	vec4 ambient;
	vec4 diffuse;
	vec4 specular;
	vec4 emission;

	float shininess;
package:
	Shader20 shader;
	PointLight *light;
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

	void setLight(PointLight* nearestlight)
	{
		light = nearestlight;
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
