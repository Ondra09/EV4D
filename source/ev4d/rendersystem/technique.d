
module ev4d.rendersystem.technique;

import ev4d.rendersystem.camera;
import ev4d.rendersystem.rendertarget;
import ev4d.rendersystem.renderqueue;

class GeneralTechnique
{
private:
	Camera cam;

public:

	abstract void render();

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
public:
	@property T scene(){ return objectsToRender; }
	@property T scene(T root){ return objectsToRender = root; }

	
	override void render()
	{
		//t.renderq.renderAll(t.camera.getView());
		sortAndRender(scene.getView());
	}

	/*@property RenderQueue renderq(){ return rtq; }
	@property RenderQueue renderq(RenderQueue concreteRtq){ return rtq = concreteRtq; }*/

}
