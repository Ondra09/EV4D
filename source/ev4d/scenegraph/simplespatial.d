
module ev4d.scenegraph.simplespatial;

import ev4d.scenegraph.scenegraphobject;
import ev4d.scenegraph.hierarchygraph;
import gl3n.linalg;

version(unittest)
{
    import std.stdio;
}

struct SpacialObject
{
private:
    mat4 transformation = mat4.identity();
    //mat4 translation;
    //mat4 scale = mat4.identity();

    bool dirtyTransform = true;

public:
    mat4 rotation = mat4.identity();
    vec3 translation = vec3(0, 0, 0);
    vec3 scale = vec3(1, 1, 1);
/+
    void setTranslation();
    void setScale(const ref vec3 scale)
    {

    }
    void rotate();+/
}

alias HierarchyGraph!(SpacialObject) SpacialHierarchyGraph;
alias SpacialHierarchyGraph SHGraph;

void recomputeTransformations(SpacialHierarchyGraph root)
{
    auto coputeTransformation = function void (SpacialHierarchyGraph node) 
                            { 
                                with(node.data)
                                {
                                    transformation =  mat4().translation(translation.x, translation.y, translation.z)*
                                                     rotation *
                                                     mat4().identity.scale(scale.x, scale.y, scale.z);

                                    if (node.parent)
                                    {
                                        transformation = node.parent.data.transformation * transformation;
                                    }
                                }

                                version(unittest)
                                {
                                    writeln(node.data.transformation);
                                }
                            };

    traverseTree!("true", // for all items
                coputeTransformation)(root);
}

unittest
{
    writeln("AAAAAAAAA");
    //create dummy tree
    // a
    // |
    // b
    // +---
    // c  d
    SpacialHierarchyGraph a = new SpacialHierarchyGraph();
    SpacialHierarchyGraph b = new SpacialHierarchyGraph();
    SpacialHierarchyGraph c = new SpacialHierarchyGraph();
    SpacialHierarchyGraph d = new SpacialHierarchyGraph();

    a ~= b;
    b ~= c;
    b ~= d;

    a.data.rotation.rotatez(PI/2);
    b.data.translation = vec3(3, -2, 5);
    c.data.scale.x = 2;
    d.data.translation = vec3(2, 2, -3);

    a.recomputeTransformations();
}

/++
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

+/
