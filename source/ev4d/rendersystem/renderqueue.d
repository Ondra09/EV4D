
module ev4d.rendersystem.renderqueue;

import ev4d.rendersystem.material;
//import ev4d.scenegraph.simplespatial;
import ev4d.rendersystem.technique;

import std.stdio;

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

void sortAndRender(T)(T[] view)
{
	foreach (T a; view)
	{
		if (a.material)
		{
			with(a.material)
			{
				worldMatrix(a.worldMatrix);
				initMaterial();
				initPass(0);
				renderPass(0);
				cleanUpPass(0);
				cleanUp();
			}
		}
	}
}
