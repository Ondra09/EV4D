
module ev4d.rendersystem.camera;

import ev4d.scenegraph.hierarchygraph;
import ev4d.rendersystem.material;
import gl3n.linalg;
import gl3n.plane;
import gl3n.frustum;

version(unittest)
{
	import ev4d.scenegraph.hierarchygraph;
}

//
class Camera
{
private: 
	// view angles
	//float fov;
	
	float e = 0; // focal length, used only with Projective camera, 0 for ortho camera

	// Viewport
	int viewportWidth;
	int viewportHeight;

	// frustum planes in camera space
	Frustum frustum;

	/**
		Frustum planes extraction in camera space.
		Different approach that in gl3n.
	*/
	void extractFrustumPlanes()
	{
		// Lengyel Mathematics for... page: 115, 116
		/*
		OPTIM : make working this

		BUG: seems it does not work
		float near = 0.5f; float far = 30.0f;
		float fovy = 90;

		float a = e * tan(fovy/2);
		Plane[6] planes;

		planes[Frustum.LEFT] = Plane(e, 0, -1, 0);
		planes[Frustum.RIGHT] = Plane(-e, 0, -1, 0);
		planes[Frustum.BOTTOM] = Plane(0, e, -a, 0);
		planes[Frustum.TOP] = Plane(0, -e, -a, 0);
		planes[Frustum.NEAR] = Plane(0, 0, -1, -near);
		planes[Frustum.FAR] = Plane(0, 0, 1, far);

		foreach (ref plane; planes)
		{
			plane.normalize();
		}
		*/

		frustum = Frustum(projMatrix);
	}

public:
	/**
		Params: width viewport width
				height viewport height
	*/
	this(int width, int height)
	{
		viewportWidth = width;
		viewportHeight = height;
	}

	void createOrtho(float left, float right, float bottom, float top, float near, float far)
	{
		projMatrix = mat4.orthographic(left, right, bottom, top, near, far);

		extractFrustumPlanes();
	}

	/**
		Params: fov y field of vision
				near
				far
	*/
	void createProjection(float fovy, float near = 0.5f, float far = 30.0f)
	{
		projMatrix = mat4.perspective(viewportWidth, viewportHeight, fovy, near, far);

		float fovx = fovy * viewportWidth/viewportHeight;
		e = 1/(tan(fovx/2));

		extractFrustumPlanes();
	}

	// TODO : hide implementation detail behind property
	// OPTIM : it would have been beneficial precompute inverse of this matrix, it is used often
	mat4 *viewMatrix;
	mat4 projMatrix;

	/// read only, camera projection is constructed from this
	@property int getViewportWidth() pure nothrow @safe { return viewportWidth; }
	@property int getViewportHeight()pure nothrow @safe { return viewportHeight; }

	/// focal length, used only with Projective camera, 0 for ortho camera
	@property float focalLength() pure nothrow @safe { return e; }

	int viewportX = 0;
	int viewportY = 0;
}

/**
	Returns:
		TODO: all visible object from given camera.
		Now returns all objects in tree, which have material.
*/
T.DataType*[] getView(T)(Camera cam, T objectsToRender)
if (is(T == class))
{
	typeof(return) retArr;

	if (objectsToRender is null)
		return retArr;

	mat4 viewM = (*cam.viewMatrix);
	viewM.invert();
	mat4 vp = cam.projMatrix * viewM;

	auto addItemDelegate = delegate void (T a) // T is class
							{ 
								if (a.data.material !is null)
								{
									
									mat4 mvpMatrix = vp * a.data.worldMatrix;
									Frustum f = Frustum(mvpMatrix);

									if (f.intersects(a.data.aabb) > 0)
									{
										retArr ~= &a.data;
									}/*else
									{
										import std.stdio;
										static int ff = 0;
										ff++;
										writeln("out", ff);
									}*/
								}
							};

	// just get all items for now
	traverseTree!("true", // for all items
		// data is struct, need only pointer
		//b => retArr ~= &b.data) // lambda function
		addItemDelegate
		)(objectsToRender);

	return retArr;
}

unittest
{	
}
