
module ev4d.rendersystem.technique;

import ev4d.rendersystem.camera;
import ev4d.rendersystem.rendertarget;

class Technique
{
private:
	RenderTarget * rtt;

	AbstractCamera cam;

protected:
public:
	@property AbstractCamera camera(){ return cam; }
	@property AbstractCamera camera(AbstractCamera concreteCam){ return cam = concreteCam; }
}
