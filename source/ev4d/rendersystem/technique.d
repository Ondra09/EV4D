
module ev4d.rendersystem.technique;

import ev4d.rendersystem.camera;
import ev4d.rendersystem.rendertarget;
import ev4d.rendersystem.renderqueue;

import derelict.opengl3.gl;

class GeneralTechnique
{
private:
	Camera cam;

public:

	abstract void render();
	abstract GeneralTechnique[] getRequiredTechniques();

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

}
