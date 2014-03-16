
module ev4d.scenegraph.bvh;

import std.typecons;
import std.typetuple;
import std.stdio;
import std.variant;
import std.traits;

/**
    Bounding volume hierarchy implementation with leafes in nodes.
*/

alias BoundingVolumeHierarchy BVM;

struct BoundingVolumeHierarchy(T) 
{
    // foreach will iterate directly over children
    alias children this;
    
    T leaf;

    BoundingVolumeHierarchy *parent;

    BoundingVolumeHierarchy[] children;

    void traverse(ref int[] result)
    {
        {
            // result grows 2k+1 so its should be ok
            result ~= leaf;

            foreach(child; children)
            {
                child.traverse(result);
            }
        }

        return;
    }
}

//
struct BVMIterator
{

}

unittest
{

}
