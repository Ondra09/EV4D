
module ev4d.rendersystem.technique;

import ev4d.rendersystem.camera;
import ev4d.rendersystem.rendertarget;
import ev4d.rendersystem.renderqueue;

import derelict.opengl3.gl;
import gl3n.linalg;

class GeneralTechnique
{
private:
	Camera cam;

public:

	abstract void render();
	abstract GeneralTechnique[] getRequiredTechniques();

	/// let technique set the camera properly
	abstract void setupCamera();

	@property Camera camera(){ return cam; }
	@property Camera camera(Camera concreteCam){ return cam = concreteCam; }
}

/**
	Technique
*/

class Technique(T) : GeneralTechnique
{
private:
	RenderTarget * rtt;
	T objectsToRender;

	// OPTIM : this 'could' be cached but care about multithreading
	//T.DataType*[] sceneViewCache;
public:
	@property T scene(){ return objectsToRender; }
	@property T scene(T root){ return objectsToRender = root; }

	override void render()
	{
		glViewport(cam.viewportX, cam.viewportY, cam.getViewportWidth, cam.getViewportHeight);

		auto sceneView = objectsToRender.getView();

		// inspect scene for aditional techniques

		sortAndRender(sceneView);
	}

	override GeneralTechnique[] getRequiredTechniques()
	{
		GeneralTechnique returnVal[];

		auto sceneView = objectsToRender.getView();

		foreach (obj; sceneView)
		{
			if (obj.material !is null)
			{
				returnVal ~= obj.material.getDependencies();
			}
		}

		return null;
	}

	override void setupCamera()
	{
		with(camera)
		{
			// width, height, fov, near, far
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			glMultMatrixf(projMatrix.value_ptr);

			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();

			//glTranslatef(0, 0, -1.0);
			mat4 viewMat = *viewMatrix;

			// column mayor to row mayor
			viewMat.transpose();

			// OPTIM : could be done with 	[ R^T | -Translate ] too 
			//								[ 0	   0    0    1 ]					
			// because camera transforms are invert to model ones
			viewMat.invert();
			glMultMatrixf(viewMat.value_ptr);
		}
	}

}
