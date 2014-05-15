
module ev4d.rendersystem.renderer;

import derelict.opengl3.gl;

import ev4d.rendersystem.technique;
import gl3n.linalg;

import ev4d.mesh.generator;
import std.stdio;

class Renderer
{
private:
protected:
public:
	GeneralTechnique[] techniques;
	
	void render()
	{
		glEnable(GL_DEPTH_TEST);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

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
///////////////////////////////////////////////////////////////////////////////////////////////
			CubeVertexesEmitor!(float) emitor;

			vec3 arrv[8];
			static float rotangle = 0;
			rotangle+=1;
			glRotatef(45, 1, 1, 1);
			glBegin(GL_POINTS);
				int i = 0;
				foreach(vec3 v; emitor)
				{
					glVertex3fv(v.value_ptr);
					arrv[i] = v;
					i++;
					//writeln(v);
				}
			glEnd();
			//writeln();

			CubeTrisEmitor!(int) trisemit;

			glBegin(GL_TRIANGLES);
				foreach (Vector!(int, 3) id; trisemit)
				{
					glColor3b(cast(byte)(id.x*20), cast(byte)(id.y*20), cast(byte)(id.z*30));

					glVertex3fv(arrv[id.x].value_ptr);
					glVertex3fv(arrv[id.y].value_ptr);
					glVertex3fv(arrv[id.z].value_ptr);
				}

			glEnd();
		}
	}
}
