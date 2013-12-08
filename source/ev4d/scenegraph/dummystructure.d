
module ev4d.scenegraph.dummystructure;

import ev4d.scenegraph.scenegraphobject;
import gl3n.linalg;

debug 
{
import std.stdio;
}

/// dummy test spatial structure
class DummyStructure
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
    
    bool conditionHolds()
    {
        return true;
    }
    
    void getLeafs()
    {
        debug
        {
            //writeln(this, children);
        }
        foreach(scg; children)
        {
            scg.getLeafs();
        }
    }

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

    DummyIterator createIterator()
    {
        return DummyIterator();
    }

    int a;
}

/// dummy test iterator
struct DummyIterator 
{
private:
    size_t index;
    DummyStructure _dummy;

public:
	this(DummyStructure dummy)
	{
        index = 0;
        _dummy = dummy;
	}

    @property bool empty() const
    {
        return (_dummy is null );
    }

    DummyStructure next()
    {

        return null;
    }

    void recomputeTransformations()
    {

    }
}

void recomputeTransformations(DummyStructure dummy)
{
}

