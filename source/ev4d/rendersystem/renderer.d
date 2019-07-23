
module ev4d.rendersystem.renderer;

import derelict.opengl;

import ev4d.rendersystem.technique;

class Renderer
{
private:
	uint frameNumber;

	GeneralTechnique[] techniquesToRender;
protected:
public:
	GeneralTechnique[] techniques;

	void render()
	{
		// let's go through all techniques and solve dependencies
		//foreach(GeneralTechnique t; techniques)

		GeneralTechnique[] techSlice = techniques;
		techniquesToRender = [];

		while (techSlice.length > 0)
		{
			GeneralTechnique t = techSlice[0];
			// very simple techniques managment, first come first serve
			// no redundancies check and order
			auto reqTechs = t.getRequiredTechniques();
			techniques ~= reqTechs;

			techniquesToRender ~= t;

			techSlice = techSlice[1..$];
		}

		// TODO : move this to individual techniques
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_CULL_FACE);
		glCullFace(GL_BACK);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		foreach(GeneralTechnique t; techniquesToRender)
		{
			if (t.camera)
			{
				t.setupCamera();
			}

			t.render();
		}

		frameNumber++;
	}
}
