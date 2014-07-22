
module ev4d.rendersystem.renderer;

import derelict.opengl3.gl;

import ev4d.rendersystem.technique;
import gl3n.linalg;

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


		glEnable(GL_DEPTH_TEST);
		glEnable(GL_CULL_FACE);
		glCullFace(GL_BACK);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		foreach(GeneralTechnique t; techniquesToRender)
		{
			if (t.camera)
			{
				with(t.camera)
				{
					// width, height, fov, near, far
					glMatrixMode(GL_PROJECTION);
					glLoadIdentity();
					glMultMatrixf(projMatrix.value_ptr);

					glMatrixMode(GL_MODELVIEW);
					glLoadIdentity();

					//glTranslatef(0, 0, -1.0);
					mat4 viewMat = *viewMatrix;

					//
					viewMat.transpose();
					// OPTIM : could be done with 	[ R^T | -Translate ] too 
					//								[ 0	   0    0    1 ]
					viewMat.invert();
					glMultMatrixf(viewMat.value_ptr);
				}
			}

			t.render();
		}

		frameNumber++;
	}
}
