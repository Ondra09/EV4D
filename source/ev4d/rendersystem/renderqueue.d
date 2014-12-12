
module ev4d.rendersystem.renderqueue;

import ev4d.rendersystem.material;
import ev4d.rendersystem.technique;
import ev4d.rendersystem.camera;
import ev4d.rendersystem.lights;

import gl3n.linalg;

// this needs to be filled in order to render
/**
this structure is needed for rq to render it properly, camera should return it in right format
*/
/*
interface RenderObject(Matrices)
//if (hasIndirections(Matrices))
{
	double keysorter; // key for sorting items in renderquee

	// this is all needed for rendering an object
	Matrices worldMatrix;
	Material mat;
	Data data;
}
*/

void sortAndRender(T)(T[] view, Camera cam, Lights *lights)
{
	assert(cam.viewMatrix, "View Matrix was not set.");
	mat4 m_viewMatrix = *cam.viewMatrix;
	mat4 m_projMatrix = cam.projMatrix;

	// OPTIM : could be done with 	[ R^T | -Translate ] too 
	//								[ 0	   0    0    1 ]					
	// because camera transforms are invert to model ones
	m_viewMatrix.invert();	
	m_viewMatrix.transpose();

	m_projMatrix.transpose();

	PointLight *nearestLight = lights.getNearestLight();

	foreach (T a; view)
	{
		if (a.material)
		{
			with(a.material)
			{
				mat4 m_worldMatrix = a.worldMatrix;
				m_worldMatrix.transpose();

				//bindData(a.renderData);
				bindVBO(a.vbo);

				{
					setLight(nearestLight);
				}

				// set matrices
				a.material.worldMatrix(m_worldMatrix);
				a.material.viewMatrix(m_viewMatrix);
				a.material.projectionMatrix(m_projMatrix);

				initMaterial();
				initPass(0);
				renderPass(0);
				cleanUpPass(0);
				cleanUp();
			}
		}
	}
}
