
module ev4d.io.texture;

import derelict.opengl3.gl;
import derelict.freeimage.freeimage;


static this()
{
	DerelictFI.load();
}

static ~this()
{
	debug
	{
		import std.stdio;
		writeln("Texture buffer count: ", textureList.length);
	}
}

private:
struct TexInfo
{
	GLuint textID = -1;
	size_t count;
}
TexInfo[string] textureList;


public:
/**
	Loads texture given by texName and buffers it. If texture is loaded multiple time only buffered GLuint is returned.
*/
GLuint loadImage(const char* texName, bool generateMipMaps = false)
{
	import std.conv;
	GLuint texture = 0;

	string texNameSd = to!(string)(texName);

	{	// texture lookup
		TexInfo* texLookup;
		
		texLookup = (texNameSd in textureList);

		debug 
		{
			import std.stdio;

			writeln("Read Texture: ", texNameSd);	
		}

		if( texLookup !is null )
		{
			(*texLookup).count++;

			debug
			{
				writeln("Found in Buffer. Count: ", (*texLookup).count);
			}
			
			return (*texLookup).textID;
		}
	}
	
	//if (texture == 0)
	{
	    FIBITMAP* bitmap = FreeImage_Load(FreeImage_GetFileType(texName, 0),texName, PNG_DEFAULT);
	    assert(bitmap);

	    glGenTextures(1, &texture);

	    glBindTexture(GL_TEXTURE_2D, texture);
	    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	    FIBITMAP *pImage = FreeImage_ConvertTo32Bits(bitmap);

		int nWidth = FreeImage_GetWidth(pImage);
		int nHeight = FreeImage_GetHeight(pImage);

		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, nWidth, nHeight,
		    0, GL_BGRA, GL_UNSIGNED_BYTE, cast
		    (void*)FreeImage_GetBits(pImage));

		if(generateMipMaps)
			glGenerateMipmap(GL_TEXTURE_2D); 

	    FreeImage_Unload(bitmap);

	    TexInfo tInfo;
	    tInfo.textID = texture;
	    tInfo.count = 1;
	    textureList[texNameSd] = tInfo;
	}

	return texture;
}

public:
/**
	Decreases usage counter of given texture. If counter == 0, than is texture deleted from OpenGL too.
*/
void deleteTexture(const char* texName)
{
	import std.conv;
	string texNameSd = to!(string)(texName);

	{	// texture lookup
		TexInfo* texLookup;
		
		texLookup = (texNameSd in textureList);
		
		if( texLookup !is null )
		{
			// decrease usage count
			(*texLookup).count--;

			if ((*texLookup).count == 0) // if usage count = 0 remove texture from Opengl and buffer
			{
				debug
				{
					import std.stdio;
					writeln("Deleting texture: ", texNameSd, " GLuint: ", (*texLookup).textID);
				}

				// delete texture from OpenGL
				deleteTexture((*texLookup).textID);

				// and delete this texture from hash map
				textureList.remove(texNameSd);
			}

		}else
		{
			assert(0, "Error, trying to delete nonloaded texture.");
		}
	}
}


private:
void deleteTexture(const GLuint id)
{
	glDeleteTextures(1, &id);
}
