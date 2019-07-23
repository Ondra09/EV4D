
module ev4d.rendersystem.text;

import std.utf;
// todo remove gl from this file and GlyphVertex_
import derelict.opengl;
import ev4d.rendersystem.material;

/**
	Definition of one glyph.
	Glyph metrics described here: http://freetype.org/freetype2/docs/tutorial/step2.html
*/
struct Glyph
{
    int width;	// width of glyph
    int height;	// height of glyph

    int bearingX; // X offset for horizontal glyphs
    int bearingY; // Y offset from baseline

    int advanceX; // advance to next glyph
    int texU;
    int texV;
}

struct GlyphVertex_
{
	@(3, GL_FLOAT)		// add atribute
	float x;	// vertex
	float y;
	float z;

	@(2, GL_FLOAT)
	float u;	// .offsetof
	float v;	// uv texture
}

/**
	Handles Font manipulation.

	Every text has now its own buffer.

	OPTIM: create some buffer where all text is shared. This would pbly need to split sceenspace/3D font rendering
	 		for optimal removing/deleting and creting new text.
*/
class Font
{
private:
	string family;
	string style;
	// size of font
	int size;
	// buffer is border of items for shader decal rendering
	int buffer;

	Glyph[immutable(dchar)] glyphMap;

	/// texture atlas size, set default size too
	float textureWidth_ = 512.0f;
	float textureHeight_ = 1024.0f;

	/**
	Creates buffer of vertexes for given text.
	*/
	GlyphVertex_[] createTextBuffer(inout string text)
	{
		GlyphVertex_[] retBuffer;

		retBuffer.reserve(text.length);

		int advance = 0;
		foreach (dchar character; text)//byChar
		{
			Glyph* glyph = character in glyphMap;

			if (glyph)
			{
				//import std.stdio;
				//writeln(character, *glyph, " > ", advance, " bearingX/Y", advance + glyph.bearingX, "/", glyph.bearingY);

				GlyphVertex_[6] coords;

				float top = buffer + glyph.bearingY;
				float height = glyph.height + buffer * 2;

				coords[0].x = advance - buffer + glyph.bearingX; // top left
				coords[0].y = 0 + top;
				coords[0].z = 0;

				coords[0].u = glyph.texU;
				coords[0].v = glyph.texV;

				coords[1].x = advance - buffer + glyph.bearingX; // bottom left
				coords[1].y = 0 + top - height;
				coords[1].z = 0;

				coords[1].u = glyph.texU;
				coords[1].v = glyph.texV + glyph.height + 2 * buffer;

				coords[2].x = advance + glyph.width + buffer + glyph.bearingX; // bottom right
				coords[2].y = 0 + top - height;
				coords[2].z = 0;

				coords[2].u = glyph.texU + glyph.width + 2 * buffer;
				coords[2].v = glyph.texV + glyph.height + 2 * buffer;

				coords[3].x = advance + glyph.width + buffer + glyph.bearingX; // bottom right
				coords[3].y = 0 + top - height;
				coords[3].z = 0;

				coords[3].u = glyph.texU + glyph.width + 2 * buffer;
				coords[3].v = glyph.texV + glyph.height + 2 * buffer;

				coords[4].x = advance + glyph.width + buffer + + glyph.bearingX; // top right
				coords[4].y = 0 + top;
				coords[4].z = 0;

				coords[4].u = glyph.texU + glyph.width + 2 * buffer;
				coords[4].v = glyph.texV;

				coords[5].x = advance - buffer + glyph.bearingX; // top left
				coords[5].y = 0 + top;
				coords[5].z = 0;

				coords[5].u = glyph.texU;
				coords[5].v = glyph.texV;

				advance += glyph.advanceX;// +buffer;

				retBuffer ~= coords;
			}
		}

		return retBuffer;
	}

	public:
	/**
		@returns texture atlas width
	*/
	@property float textureWidth() pure nothrow
	{
		return textureWidth_;
	}

	@property float textureWidth(float width)
	{
		return textureWidth_ = width;
	}

	/**
		@returns texture atlas height
	*/
	@property float textureHeight() pure nothrow
	{
		return textureHeight_;
	}

	@property float textureHeight(float height)
	{
		return textureHeight_ = height;
	}

	/**
	Crates VBO for given text rendering. Don't use Index buffer use GL_TRIANGLES for draw instead.
	@returns number of quads to render
	*/
	size_t createTextVBO(ref VBO vbo, inout string text, bool dynamic = false)
	{
		// create new only if empty else reuse buffer
		if (vbo.vboIDs.length == 0)
		{
			genBuffers(vbo, 1);
		}

		GLenum usage = GL_STATIC_DRAW;
		if (dynamic)
		{
			usage = GL_DYNAMIC_DRAW;
		}

		GlyphVertex_[] buffer = createTextBuffer(text);

		foreach(ref GlyphVertex_ v; buffer)
		{
			v.u /= textureWidth_;
			v.v /= textureHeight_;
			v.v = 1.0 - v.v;	// 0,0 is bottom left
		}

		bindBufferAndData!(GlyphVertex_)(vbo.vboIDs[0], buffer, GL_ARRAY_BUFFER, usage);
		vbo.itemsCount[0] = cast(int)buffer.length;

		// no index buffer, draw as quads
		return buffer.length;
	}

}

Font createFont(string fontFile)
{
	Font font = new Font();
	font.loadTextData(fontFile);

	return font;
}

Node createTextNode(Node)(Font font, ref VBO vboText, inout string text, Material shader, bool dynamic = false)
{
	font.createTextVBO(vboText, text, dynamic);

	Node textNode = new Node();

	textNode.data.material = shader;
    textNode.data.vbo = &vboText;

	return textNode;
}

/**
	Loads text data.
*/
void loadTextData(Font font, in string fileName)
{
    import std.file;
    import std.json;
    import std.conv;

    string json = readText(fileName);

    JSONValue[string] jsv = parseJSON(json).object;

    font.family = jsv["family"].str;
    font.style = jsv["style"].str;
    font.buffer = cast(int)jsv["buffer"].integer;
    font.size = cast(int)jsv["size"].integer;

    JSONValue[string] arrS = jsv["chars"].object;

    foreach (i, ss; jsv["chars"].object)
    {
        Glyph glyph;

        JSONValue[] jArray = ss.array;

        dchar di = to!(dchar)(i[0..stride(i, 0)]);

        if (i == " ") // space is special case
        {
        	glyph.width = cast(int)jArray[0].integer;
            glyph.height = cast(int)jArray[1].integer;
            glyph.bearingX = cast(int)jArray[2].integer;
            glyph.bearingY = cast(int)jArray[3].integer;
            glyph.advanceX = cast(int)jArray[4].integer;

            glyph.texU = 0;
            glyph.texV = 0;

        	font.glyphMap[di] = glyph;
        }
        else if (jArray.length > 5)
        {
            glyph.width = cast(int)jArray[0].integer; // tell compiler to shut up
            glyph.height = cast(int)jArray[1].integer;
            glyph.bearingX = cast(int)jArray[2].integer;
            glyph.bearingY = cast(int)jArray[3].integer;
            glyph.advanceX = cast(int)jArray[4].integer;

            glyph.texU = cast(int)jArray[5].integer;
            glyph.texV = cast(int)jArray[6].integer;

            font.glyphMap[di] = glyph;
        }
    }
}
