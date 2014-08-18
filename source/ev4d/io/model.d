module ev4d.io.model;

import derelict.assimp3.assimp;
import derelict.opengl3.gl;


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
	float x;
	float y;
	float z;

	float nx;
	float ny;
	float nz;

	float tx;
	float ty;
	float tz;

	float u;
	float v;
}


// currently loads only one mesh with static data
// and one texture coords
// seems like assimp is not loading correctly s flag = smmothing groups
// maybe write own importer2
bool testImport  (ref VBO vbo, string filename = "")
{

	import std.stdio;
	import std.path;

	const aiScene * scene = aiImportFile( "objects/Space Frigate 6/space_frigate_6/space_frigate_6.obj", 
										    	aiProcess_CalcTangentSpace       | 
										        aiProcess_Triangulate            |
										        aiProcess_JoinIdenticalVertices  |
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
			vertex.x = mesh.mVertices[j].x;
			vertex.y = mesh.mVertices[j].y;
			vertex.z = mesh.mVertices[j].z;

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
	}

	
	//writeln(vboContent);
	//writeln(vboContent.indices);

	// Now we can access the file's contents
	//DoTheSceneProcessing( scene);

	// We're done. Release all resources associated with this import
	aiReleaseImport( scene );

	return true;
}
