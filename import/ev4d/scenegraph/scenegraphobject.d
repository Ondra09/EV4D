
module ev4d.scenegraph.scenegraphobject;

class SceneGraphObject
{

}

class Group(T...) : SceneGraphObject
{
    static if (T.length)
    {
        //foreach ()
    }
    T[0] sds;

    /// function traverse sdss and instancies returns 
    /// iterator for particular one according to proper type
    void traverseSubnodes(){}
}

class Leaf : SceneGraphObject
{

}

