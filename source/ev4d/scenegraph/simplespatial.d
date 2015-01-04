
module ev4d.scenegraph.simplespatial;

import ev4d.scenegraph.hierarchygraph;
import ev4d.rendersystem.material;
import gl3n.linalg;
import gl3n.frustum;

version(unittest)
{
    import std.stdio;
}

/**
    
*/
struct SpacialObject
{
private:
    bool useDirectTransform = false;

public:
    long sortKey;

    AABB aabb;

    mat4 transformation = mat4.identity();

    mat4 rotationM = mat4.identity();
    mat4 scaleM = mat4.identity();
    mat4 translationM = mat4.identity();

    alias worldMatrix = transformation;

    //TODO:  who hold this? -- loader manager pbly? or level manager?
    VBO* vbo;

    Material material;

    /**
        If true, transformations are not computed and is always taken what is in transformation matrix directly.
        If false, transformations are recomputed like this transformation = translationM * scaleM * rotationM;
    */
    @property bool directTransformation(){ return useDirectTransform; }
    @property bool directTransformation(bool directly){ return useDirectTransform = directly; }
}

alias HierarchyGraph!(SpacialObject) SpacialHierarchyGraph;
alias SpacialHierarchyGraph SHGraph;

void recomputeTransformations(SpacialHierarchyGraph root)
{
    auto coputeTransformation = function void (SpacialHierarchyGraph node) 
                            { 
                                with(node.data)
                                {
                                    if (!useDirectTransform)
                                    {
                                        // OPTIM: recompute lazily

                                        transformation = translationM * rotationM * scaleM;
                                    }
                                }

                                if (node.parent)
                                {
                                    //node.data.transformation =  node.data.transformation * node.parent.data.transformation;
                                    node.data.transformation =  node.parent.data.transformation * node.data.transformation;
                                }
                            };

    traverseTree!("true", // for all items
                coputeTransformation)(root);
}

unittest
{
    writeln(__FUNCTION__);
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

    // thiz is not so weird
    a.data.rotationM.rotatez(PI/2);
    a.data.translationM.translate(3, -2, 5);

    // thiz is weird
    b.data.translationM.translate(3, -2, 5);

    // thiz is weird
    c.data.scaleM.scale(1, 2, -3);

    assert(c.data.scaleM.matrix == [[1.0f, 0.0f, 0.0f, 0.0f],
                                   [0.0f, 2.0f, 0.0f, 0.0f],
                                   [0.0f, 0.0f, -3.0f, 0.0f],
                                   [0.0f, 0.0f, 0.0f, 1.0f]]);

    // this is better
    d.data.translationM = mat4.translation(1.0f, 2.0f, -3.0f);

    assert(d.data.translationM.matrix == [  [1.0f, 0.0f, 0.0f, 1.0f],
                                            [0.0f, 1.0f, 0.0f, 2.0f],
                                            [0.0f, 0.0f, 1.0f, -3.0f],
                                            [0.0f, 0.0f, 0.0f, 1.0f]]);

    a ~= b;
    b ~= c;
    b ~= d;

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
