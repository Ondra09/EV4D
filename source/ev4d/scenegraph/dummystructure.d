module ev4d.scenegraph.dummystructure;

import ev4d.scenegraph.scenegraphobject;

/// dummy test spatial structure
class DummyStructure
{
private: 
    SceneGraphObject children[];

public:    
	this()
	{
		// Constructor code
	}

    void addChild(SceneGraphObject child)
    {
        children ~= child;
    }
}

/// dummy test iterator
class DummyIterator 
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

}

