
module ev4d.io.texture;

import derelict.opengl;
import derelict.util.exception : ShouldThrow;

import derelict.freeimage.freeimage;

import std.experimental.logger;

import std.algorithm;


/**
Module handles very basic of loading textures.
*/

ShouldThrow myMissingSymCB( string symbolName )
{
    string[] ignoreList = ["FreeImage_JPEGTransform", "FreeImage_JPEGTransformU",
    "FreeImage_JPEGCrop", "FreeImage_JPEGCropU",
    "FreeImage_JPEGTransformFromHandle", "FreeImage_JPEGTransformFromHandleU"

    ];

    if (ignoreList.find(symbolName))
    {
        return ShouldThrow.No;
    }
    else
    {
        return ShouldThrow.Yes;
    }
}

/*
Basically global variables, I think it is ok for now.
We don't want to have multiple copies of texture in applicaiton anywhere across all scenes.
*/
static this()
{
    DerelictFI.missingSymbolCallback = &myMissingSymCB;
	DerelictFI.load();
}

static ~this()
{
	debug
	{
		log("Texture buffer count: ", textureList.length);

		if (textureList.length > 0)
		{
			// clear all
			warning("Clearing nonempty texture buffer.");
			clearAllTextures();
			assert(textureList.length == 0);
		}
	}
}

private:
struct TexInfo
{
	GLuint textID = -1;
	size_t count;
}

// this is global over whole application, we don't have same texture twice
TexInfo[string] textureList;

// this texture will load as default, when wanted texture does not exist.
// and log this as error
char* defaultTexture = null;

public:
/**
	Loads texture given by texName and buffers it. If texture is loaded multiple time only buffered GLuint is returned.

	@return GLuint identifier of texture in OpenGL context ready for binding.
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
			info("Read Texture: ", texNameSd);
		}

		if( texLookup !is null )
		{
			(*texLookup).count++;

			debug
			{
				info("Found in Buffer. Count: ", (*texLookup).count);
			}

			return (*texLookup).textID;
		}
	}

	{
	    FIBITMAP* bitmap = FreeImage_Load(FreeImage_GetFileType(texName, 0), texName, PNG_DEFAULT);

	    if (bitmap == null && defaultTexture != null)
	    {
	    	// try to load default
	    	bitmap = FreeImage_Load(FreeImage_GetFileType(defaultTexture, 0), defaultTexture, PNG_DEFAULT);
	    }

	    if (bitmap)
	    {

		    FIBITMAP *pImage = FreeImage_ConvertTo32Bits(bitmap);

			int nWidth = FreeImage_GetWidth(pImage);
			int nHeight = FreeImage_GetHeight(pImage);

			texture = createTexture(cast(void*)FreeImage_GetBits(pImage), nWidth, nHeight, generateMipMaps);

		    FreeImage_Unload(bitmap);
	    }
	    else
	    {
	    	int nWidth = 1;
	    	int nHeight = 1;
	    	char[4] img = [255, 0, 255, 255];

	    	log("ERROR :: Texture loading failed: ", texNameSd);

	    	texture = createTexture(cast(void*)img, nWidth, nHeight, generateMipMaps);
	    }

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
					info("Deleting texture: ", texNameSd, " GLuint: ", (*texLookup).textID);
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

void clearAllTextures()
{
	foreach (ref TexInfo item; textureList.byValue())
	{
		(item).count = 0;
		deleteTexture((item).textID);
		item.textID = 0;
	}

	foreach (key; textureList.keys)
	{
        textureList.remove(key);
    }
}

public:
//@property
void setDefaultTexture(char* defaultTex)
{
	defaultTexture = defaultTex;
}

char* getDefaultTexture()
{
	return defaultTexture;
}

private:
void deleteTexture(const GLuint id)
{
	glDeleteTextures(1, &id);
}

GLuint createTexture(void* data, int width, int height, bool generateMipMaps)
{
	GLuint texture;

	glGenTextures(1, &texture);

    glBindTexture(GL_TEXTURE_2D, texture);
    // TODO: use mipmaps!
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height,
			    0, GL_BGRA, GL_UNSIGNED_BYTE, data);

    if(generateMipMaps)
		glGenerateMipmap(GL_TEXTURE_2D);

	return texture;
}
