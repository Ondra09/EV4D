
module ev4d.scenegraph.scenegraphobject;

import std.typecons;

class SceneGraphObject
{

}

class Group(T...) : SceneGraphObject
if (isTuple!T)
{
    /// Spatial data structures
    T sds;

    static if (T.length)
    {
        //foreach ()
    }
    
    /// function traverse sdss and instancies returns 
    /// iterator for particular one according to proper type
    void traverseSubnodes(){}
}

class Leaf : SceneGraphObject
{

}

