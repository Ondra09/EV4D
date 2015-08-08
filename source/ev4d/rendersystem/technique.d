
module ev4d.rendersystem.technique;

import ev4d.rendersystem.camera;
import ev4d.rendersystem.rendertarget;
import ev4d.rendersystem.renderqueue;

import ev4d.tools.numeric;

import gl3n.linalg;
import derelict.opengl3.gl;

import ev4d.rendersystem.lights;

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
	Crates sorting key.
	Params:
		object = renderable object
		cam = current camera
	Returns: sorting key
*/
long createSortKey(T)(T* object, Camera cam)
{
	long sortKey = 0;

	ptrdiff_t matID;
			
	matID = object.material.getID();

	////////////////////////////////////////////////////////////
	// compute distance to camera of object, get rough idea ...

	mat4 m_viewMatrix = *cam.viewMatrix;
	m_viewMatrix.invert();

	mat4 modelViewMatrix = m_viewMatrix * object.worldMatrix;

	vec4 worldPos = modelViewMatrix * vec4(0, 0, 0, 1); // use z directly to have linearized space
	float dst = -worldPos.z;

	// this occurs when pivot of object behind camera, but aabb crosses camera visible frustum
	if (dst < 0) // think about this problem more how to solve it, or maybe this one is good solution
	{
		dst = 0; 
	}

	/*
	TODO : use this when we have correct set of items from camera : no items behind camera etc..
	vec4 posProj = cam.projMatrix * modelViewMatrix * vec4(0, 0, 0, 1);
	if (posProj.w != 0)
		posProj /= posProj.w;

	float dst = posProj.z + 1.0; // -1..1 to 0..2
	*/

	//import std.stdio;
	//writeln(worldPos, " : ", posProj);
	////////////////////////////////////////////////////////////

	// reset key for to be sure
	sortKey = 0;

	sortKey = matID;
	sortKey <<= 20; 
	sortKey |= floatToBitsPositive!(20)(dst);

	return sortKey;
}

/**
	Technique
	Params:
		T = object to operate on
		funCreateSortKey = function that generates sorting key 
*/
class Technique(T, alias funCreateSortKey) : GeneralTechnique
if (is (typeof(funCreateSortKey)==function))
{
private:
	RenderTarget * rtt;
	T objectsToRender;

	// OPTIM : this 'could' be cached but care about multithreading
	//T.DataType*[] sceneViewCache;
public:
	@property T scene(){ return objectsToRender; }
	@property T scene(T root){ return objectsToRender = root; }

	Lights lights;

	override void render()
	{
		glViewport(cam.viewportX, cam.viewportY, cam.getViewportWidth, cam.getViewportHeight);

		auto sceneView = cam.getView(objectsToRender);

		// create sorting keys
		foreach (ref object; sceneView)
		{
			object.sortKey = funCreateSortKey(object, cam);


		}
		//

		sortAndRender(sceneView, camera, &lights);
	}

	/**
	Run through all techniques in materials and return them.
	*/
	override GeneralTechnique[] getRequiredTechniques()
	{
		GeneralTechnique[] returnVal;

		auto sceneView = cam.getView(objectsToRender);

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
			/*
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();

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

			*/
		}
	}

}
