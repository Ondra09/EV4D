
module ev4d.rendersystem.material;
// todo switch to gl2 or gl3
import derelict.opengl3.gl;

class Material
{
	//nofpasses
	// now just dummy funciton name and all
	void Render()
	{
		glBegin(GL_POINTS);
		glEnd();
	}
}
