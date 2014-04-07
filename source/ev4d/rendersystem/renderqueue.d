
module ev4d.rendersystem.renderqueue;

class RenderQueue(T)
{
private:
	T sceneRoot;
	RenderTarget* rtt;
public:
	@property T scene(){ return sceneRoot; }
	@property T scene(T root){ return sceneRoot = root; }

}