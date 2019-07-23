module ev4d.io.model;

import derelict.assimp3.assimp;
import derelict.opengl3.gl;
import gl3n.aabb;
import gl3n.linalg;
import gl3n.frustum;

import ev4d.rendersystem.material;

import std.experimental.logger;

// not used for now
enum FighterVBODescr
{
	INDEX,		// 0
	VERTEX,		// 1
	NORMAL,		// 2
	TANGENT,	// 3
	TEXTURE 	// 4 .max
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


// currently loads only one mesh with static data
// and one texture coords
// seems like assimp is not loading correctly s flag = smmothing groups
// maybe write own importer
bool testImport (ref VBO vbo, ref AABB aabb, string filename = "")
{
	import std.stdio;
	import std.path;

	const aiScene * scene = aiImportFile( "objects/work/Space Frigate 6/space_frigate_6/space_frigate_6.obj",
										    	aiProcess_CalcTangentSpace       |
										        aiProcess_Triangulate            |
										        //aiProcess_JoinIdenticalVertices  |
										        aiProcess_SortByPType
										        );

	// If the import failed, report it
	if( !scene )
	{
		critical("Error loading map file: ", absolutePath(filename));
		//DoTheErrorLogging( aiGetErrorString());
		return false;
	}

	uint meshes = scene.mNumMeshes;

	//VBO vboContent; // interleaved array
	GameVertex_[] vboContent;
	uint[] indices;

	GameVertex_ vertex;

	genBuffers(vbo, scene.mNumMeshes);

	//writeln("Num meshes: ", scene.mNumMeshes);
	// TODO : think more about VBO & meshes when we have more meshes in model.. or across models
	assert (scene.mNumMeshes == 1);

	AABB[] aabbs = [];
	aabbs.reserve(scene.mNumMeshes);

	foreach (uint i; 0..scene.mNumMeshes)
	{
		auto mmeshes = scene.mMeshes;
		auto mesh = mmeshes[i];

		vboContent = [];
		vboContent.reserve(mesh.mNumVertices);

		AABB aabbl;

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

			vertex.u = mesh.mTextureCoords[0][j].x; // only one texture coords at time
			vertex.v = mesh.mTextureCoords[0][j].y;
			//writeln(vertex.tx, " x ", vertex.ty, " x ", vertex.tz);
			vec3 v = vec3(vertex.x, vertex.y, vertex.z);
			aabbl.expand(v);

			vboContent ~= vertex;
		}

		aabbs ~= aabbl;

		bindBufferAndData!(GameVertex_)(vbo.vboIDs[i], vboContent);

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

		vbo.itemsCount[i] = cast(int)indices.length;
		bindBufferAndData!(uint)(vbo.idxIDs[i], indices, GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW);

		// writeln(indices.length);
	}


	//writeln(vboContent);
	//writeln(vboContent.indices.length);

	// Now we can access the file's contents
	//DoTheSceneProcessing( scene);

	// We're done. Release all resources associated with this import
	aiReleaseImport( scene );

	aabb = aabbs[0];

	return true;
}
