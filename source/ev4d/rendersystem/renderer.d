
module ev4d.rendersystem.renderer;

import derelict.opengl3.gl;

import ev4d.rendersystem.technique;
import gl3n.linalg;

import std.stdio;
import ev4d.mesh.generator;

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
					// OPTIM : could be done with 	[ R^T | -Transpose ] too 
					//								[ 0	   0    0    1 ]
					viewMat.invert();
					glMultMatrixf(viewMat.value_ptr);
				}
			}

			t.render();

			CubeVertexesEmitor!(float) emitor;
			glRotatef(45, 1, 1, 1);
			glBegin(GL_POINTS);
				foreach(vec3 v; emitor)
				{
					glVertex3fv(v.value_ptr);
					writeln(v);
				}
			glEnd();
			writeln();
		}
	}
}
