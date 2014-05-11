
module ev4d.rendersystem.renderer;

import derelict.opengl3.gl;

import ev4d.rendersystem.technique;

class Renderer
{
private:
protected:
public:
	GeneralTechnique[] techniques;
	
	void render()
	{
		glClear(GL_COLOR_BUFFER_BIT);
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		//hardoceded for now
		glFrustum(-1.2, 1.2, -1, 1, 0.5, 20);

		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();

		glTranslatef(0, 0, -1.0);

		foreach(GeneralTechnique t; techniques)
		{
			t.render();
		}
	}
}
