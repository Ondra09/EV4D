
module ev4d.rendersystem.renderqueue;

import ev4d.rendersystem.technique;
import ev4d.scenegraph.simplespatial;
import ev4d.rendersystem.material;

import std.stdio;

class RenderQueue
{
private:
protected:
public:

	Technique[] renderq;

	void renderAll()
	{
		foreach (Technique t; renderq)
		{
			auto view = t.camera.getView();
			
			foreach (Material a; view)
			{
				a.render();
			}
		}
	}

}