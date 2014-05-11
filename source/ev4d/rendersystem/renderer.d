
module ev4d.rendersystem.renderer;

import ev4d.rendersystem.technique;

class Renderer
{
private:
protected:
public:
	GeneralTechnique[] techniques;
	
	void render()
	{
		foreach(GeneralTechnique t; techniques)
		{
			t.render();
		}
	}
}
