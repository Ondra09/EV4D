
module ev4d.io.texture;

import derelict.opengl3.gl;
import derelict.freeimage.freeimage;


static this()
{
	DerelictFI.load();
}


GLint loadImage(const char* texName, bool generateMipMaps = false)
{
	GLuint texture = 0;
	
	if (texture == 0)
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
	}

	return texture;
}

void deleteTexture(const GLuint id)
{
	glDeleteTextures(1, &id);
}
