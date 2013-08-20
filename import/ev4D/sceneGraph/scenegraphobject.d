
module ev4d.scenegraph.scenegraphobject;

class SceneGraphObject
{

}

class Group(SpacialStructure) : SceneGraphObject
{
	SpacialStructure[] container;
}

class Leaf : SceneGraphObject
{
}
