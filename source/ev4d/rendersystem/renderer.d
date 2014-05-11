
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

		foreach(GeneralTechnique t; techniques)
		{
			t.render();
		}
	}
}
