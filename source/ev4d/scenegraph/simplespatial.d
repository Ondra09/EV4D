
module ev4d.scenegraph.simplespatial;

import ev4d.scenegraph.scenegraphobject;
import gl3n.linalg;

debug 
{
import std.stdio;
}

/// dummy test spatial structure
class SimpleSpatial
{
private: 
    SceneGraphObject children[];
    /// lazily computed current transformation
    mat4 transformation = mat4.identity();
    // transformations need to be recomputed
    bool dirtyTransform = true;
public:
    /// local space coordination change
    mat4 rotation = mat4.identity();
    vec3 translation = vec3(0, 0, 0);
    vec3 scale = vec3(1, 1, 1);

    // foreach will iterate directly over children
    alias children this;

	this()
	{
		// Constructor code
	}

    void addChild(SceneGraphObject child)
    {
        children ~= child;
    }
    void setTraversalCondition(bool recursively)
    {
        return;
    }
       
    void getLeafs(Comp cmp)
    {
        debug
        {
            //writeln(this, children);
        }
        /*foreach(scg; children)
        {
            scg.getLeafs();
        }*/
    }
    
    ///
    /*
    int opApply(int delegate(ref SceneGraphObject) dg)
    {
        int result = 0;

        foreach(child; children)
        {
            result = dg(child);
        }

        if (result)
            return result;

        return result;
    }*/

    mat4 getTransform()
    {
        if (dirtyTransform)
        {
            dirtyTransform = false;
            transformation =    mat4().translation(translation.x, 
                                                    translation.y, 
                                                    translation.z)*
                                rotation *
                                mat4().identity.scale(scale.x, scale.y, scale.z);

        }
        return transformation;
    }

    SimpleSpatialIterator createIterator()
    {
        return SimpleSpatialIterator();
    }

    int a;
}

/// dummy test iterator
struct SimpleSpatialIterator 
{
private:
    size_t index;
    SimpleSpatial _dummy;

public:
	this(SimpleSpatial dummy)
	{
        index = 0;
        _dummy = dummy;
	}

    @property bool empty() const
    {
        return (index == _dummy.children.length);
    }

    SceneGraphObject next()
    {

        return _dummy.children[index++];
    }

    
}

void recomputeTransformations(SimpleSpatial dummy)
{
}

