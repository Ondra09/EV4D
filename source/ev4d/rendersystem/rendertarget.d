
module ev4d.rendersystem.rendertarget;

class RenderTarget(T)
{
private:
	T sceneRoot;

public:
	@property T scene(){ return sceneRoot; }
	@property T scene(T root){ return sceneRoot = root; }



}