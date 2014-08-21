module ev4d.io.model;

import derelict.assimp3.assimp;
import derelict.opengl3.gl;

// not used for now
enum FighterVBODescr
{
	INDEX,		// 0
	VERTEX,		// 1
	NORMAL,		// 2
	TANGENT,	// 3
	TEXTURE 	// 4 .max
}


struct VBO
{
	GLuint[] vboIDs;
	uint[] idxIDs;
}

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

void delBuffers(ref VBO vbo)
{
	glDeleteBuffers(cast(int)vbo.vboIDs.length, vbo.vboIDs.ptr);
}


struct GameVertex_
{
	@(3, GL_FLOAT)		// add atribute
	float x;	// vertex
	float y;
	float z;

	@(3, GL_FLOAT)
	float nx;	// .offsetof
	float ny;	// normals
	float nz;

	@(3, GL_FLOAT)
	float tx;	// .offsetof
	float ty;	// tangent
	float tz;

	@(2, GL_FLOAT)
	float u;	// .offsetof
	float v;	// uv texture
}


void setVBOVertexPointers(Vertex)()
{
	static if (__traits(hasMember, Vertex, "x"))
	{
		static assert(__traits(getAttributes, Vertex.x)[0] == (3));

		glVertexPointer(__traits(getAttributes, Vertex.x)[0], 
						__traits(getAttributes, Vertex.x)[1], 
						GameVertex_.sizeof, cast(void*)(Vertex.x.offsetof));
	}

	static if (__traits(hasMember, Vertex, "nx"))
	{
		glColorPointer(	__traits(getAttributes, Vertex.nx)[0], 
						__traits(getAttributes, Vertex.nx)[1], 
						GameVertex_.sizeof, cast(const void*)(Vertex.nx.offsetof) );
	}

	static if (__traits(hasMember, Vertex, "nx"))
	{
		glNormalPointer(__traits(getAttributes, Vertex.nx)[0], 
						__traits(getAttributes, Vertex.nx)[1], 
						GameVertex_.sizeof, cast(const void*)(Vertex.nx.offsetof) );
	}

	static if (__traits(hasMember, Vertex, "tx"))
	{
		glTexCoordPointer(	__traits(getAttributes, Vertex.nx)[0],
							__traits(getAttributes, Vertex.nx)[1], 
							GameVertex_.sizeof, cast(const void*)(Vertex.nx.offsetof) );
	}
}


// currently loads only one mesh with static data
// and one texture coords
// seems like assimp is not loading correctly s flag = smmothing groups
// maybe write own importer
bool testImport (ref VBO vbo, string filename = "")
{

	import std.stdio;
	import std.path;

	const aiScene * scene = aiImportFile( "objects/Space Frigate 6/space_frigate_6/space_frigate_6.obj", 
										    	aiProcess_CalcTangentSpace       | 
										        aiProcess_Triangulate            |
										        //aiProcess_JoinIdenticalVertices  |
										        aiProcess_SortByPType
										        );

	// If the import failed, report it
	if( !scene )
	{
		writeln("Error loading map file: ", absolutePath(filename));
		//DoTheErrorLogging( aiGetErrorString());
		return false;
	}

	uint meshes = scene.mNumMeshes;

	//VBO vboContent; // interleaved array
	GameVertex_[] vboContent;
	uint[] indices;

	GameVertex_ vertex;

	genBuffers(vbo, scene.mNumMeshes);
	//delBuffers(vbo0);

	//writeln("Num meshes: ", scene.mNumMeshes);
	// TODO : think more about VBO & meshes when we have more meshes in model.. or across models
	assert (scene.mNumMeshes == 1);

	foreach (uint i; 0..scene.mNumMeshes)
	{
		auto mmeshes = scene.mMeshes;
		auto mesh = mmeshes[i];

		vboContent = [];
		vboContent.reserve(mesh.mNumVertices);

		assert (mesh.mNormals);
		assert (mesh.mTangents);

		foreach (uint j; 0..mesh.mNumVertices)
		{
			//writeln(mesh.mVertices[j]);
			float scale = 1.0f/16.0f;
			vertex.x = mesh.mVertices[j].x * scale;
			vertex.y = mesh.mVertices[j].y * scale;
			vertex.z = mesh.mVertices[j].z * scale;

			vertex.nx = mesh.mNormals[j].x;
			vertex.ny = mesh.mNormals[j].y;
			vertex.nz = mesh.mNormals[j].z;

			vertex.tx = mesh.mTangents[j].x;
			vertex.ty = mesh.mTangents[j].y;
			vertex.tz = mesh.mTangents[j].z;

			vertex.u = mesh.mTextureCoords[0].x; // only one texture coords at time
			vertex.v = mesh.mTextureCoords[0].y;

			//
			vboContent ~= vertex;
		}

		glBindBuffer(GL_ARRAY_BUFFER, vbo.vboIDs[i]);
		glBufferData(GL_ARRAY_BUFFER, GameVertex_.sizeof*vboContent.length, vboContent.ptr, GL_STATIC_DRAW);
		
		

		glBindBuffer(GL_ARRAY_BUFFER, 0);

		indices = [];
		indices.reserve(mesh.mNumFaces*3);
		foreach (uint j; 0..mesh.mNumFaces)
		{
			//writeln(mesh.mFaces[j]);
			assert (mesh.mFaces[j].mNumIndices == 3);
			indices ~= mesh.mFaces[j].mIndices[0];
			indices ~= mesh.mFaces[j].mIndices[1];
			indices ~= mesh.mFaces[j].mIndices[2]; 
		}

		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo.idxIDs[i]);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, uint.sizeof*indices.length, indices.ptr, GL_STATIC_DRAW);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

		// writeln(indices.length);
	}

	
	//writeln(vboContent);
	//writeln(vboContent.indices.length);

	// Now we can access the file's contents
	//DoTheSceneProcessing( scene);

	// We're done. Release all resources associated with this import
	aiReleaseImport( scene );

	return true;
}
