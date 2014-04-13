
module ev4d.rendersystem.material;
// todo switch to gl2 or gl3
import derelict.opengl3.gl;

import std.stdio;

struct RenderData
{
	float vertexes[];
}

class Material
{
	RenderData renderdata;
	this()
	{
		renderdata.vertexes = new float[3];
	}
	//nofpasses
	// now just dummy funciton name and all
	void render()
	{ //writeln(&renderdata.vertexes);
		glColor3b(1, 0, 1);
		glBegin(GL_POINTS);

			glVertex3fv(renderdata.vertexes.ptr);
			//glVertex3f(renderdata.vertexes[0], renderdata.vertexes[1], renderdata.vertexes[2]);

		glEnd();
	}
}
