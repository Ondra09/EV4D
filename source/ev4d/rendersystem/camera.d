
module ev4d.rendersystem.camera;

import ev4d.scenegraph.hierarchygraph;
import ev4d.rendersystem.material;
import gl3n.linalg;

version(unittest)
{
	import ev4d.scenegraph.hierarchygraph;
}

//
class Camera
{
private: 
	// view angles
	float fov;

	// Viewport
	int viewportWidth;
	int viewportHeight;
public:
	this(int width, int height, float fov, float near = 0.5f, float far = 30.0f)
	{
		this.fov = fov;
		viewportWidth = width;
		viewportHeight = height;

		projMatrix = mat4.perspective(viewportWidth, viewportHeight, fov, near, far);
	}
	// TODO : hide implementation detail behind property
	mat4 *viewMatrix;
	mat4 projMatrix;

	/// read only, camera projection is constructed from this
	@property int getViewportWidth(){ return viewportWidth; }
	@property int getViewportHeight(){ return viewportHeight; }

	int viewportX = 0;
	int viewportY = 0;
}

/**
	return: all visible object from given camera.
*/
T.DataType*[] getView(T)(T objectsToRender)
{
	typeof(return) retArr;

	if (objectsToRender is null)
		return retArr;

	// just get all items for now
	traverseTree!("true", // for all items
		// data is struct, need only pointer
		b => retArr ~= &b.data )(objectsToRender);

	return retArr;
}

unittest
{	
}
