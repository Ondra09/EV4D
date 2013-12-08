
module ev4d.scenegraph.scenegraphobject;

import std.typecons;
import std.typetuple;
import std.stdio;
import std.variant;
import ev4d.scenegraph.dummystructure;
import std.traits; 
class SceneGraphObject
{
    abstract void getLeafs();
}
mixin template make_method(T, string name = null)
{
    //mixin("void pes(T t){writeln(\"Cokl\", t"~"); }");
    mixin("int opApply(int delegate(T) dg)
    {
        int result = 0;

        foreach(s; sds)
        {
            s.opApply(dg);
        }

        return result;
    }");
}

class Group(T...) : SceneGraphObject
{
    /// Spatial data structures
    //public RefCounted!(Tuple!(T), RefCountedAutoInitialize.no) sds;

    Tuple!(T) sds;
    alias Types =TypeTuple!(sds.Types);

    alias sds this;

    static if (T.length)
    {
        //foreach ()
    }

    /// Sets traversal condition and apply to all children if recursivly == true
    void setTraversalCondition(bool recursively)
    {
        foreach(s; sds)
        {
            s.setTraversalCondition(recursively);
        }
    }

    //mixin make_method!(Types[0]);

    /*int opApply(int delegate( Variant) dg)
    {
        int result = 0;

        foreach(s; sds)
        {
            //s.opApply(dg);
        }

        return result;
    }*/
 
    /// function traverse sdss and instancies returns 
    /// iterator for particular one according to proper type
    override void getLeafs()
    {
        foreach(s; sds)
        {
            s.getLeafs();
        }
    }
    auto getIterators()
    {
        foreach(s; sds)
        {
            return s.createIterator();
        }
    }
    /*
    /// input range
    struct Range
    {
        int _index = 0;
        Tuple!(T) _sds;
        private this(Tuple!(T) sds)
        { 
            _index = 0;
            _sds = sds;
        }

        invariant()
        {
            assert(_index <= _sds.length);
        }

        @property auto ref front()
        {
            return _index;
            //writeln("Range front");
            //return _sds[_index];
        }
        void popFront(){ ++_index; }
        @property bool empty() const { return (_index == _sds.length); }
    }

    Range opSlice()
    {
        return Range(sds);
    }*/
}

class Leaf : SceneGraphObject
{
    static int a = 0;
    override void getLeafs()
    {
        writeln("Leaf kokot", a++);
    }
}
