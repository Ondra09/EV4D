
module ev4d.scenegraph.scenegraphobject;

import std.typecons;
import std.typetuple;
import std.stdio;
import std.variant;
import std.traits;

<<<<<<< HEAD
/++
=======

alias Comp = bool delegate(SceneGraphObject);

>>>>>>> FETCH_HEAD
class SceneGraphObject
{
    abstract void getLeafs(Comp);
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
    static assert (T.length == 1 || T.length == 2);
    static if (T.length == 2)
    {
        static assert (is(typeof(T[1]) : string));
    }

    Tuple!(T) sds;

    alias sds this;

    void aaa()
    {
        writeln("aaa");
    }

    /// function traverse sdss and instancies returns 
    /// iterator for particular one according to proper type
    override void getLeafs(Comp cmp)
    {
<<<<<<< HEAD
        foreach(s; sds)
        {
            s.getLeafs();
        }
    }
}+/
=======
        sds[0].getLeafs(cmp);
    }

    ///
    /*int opApply(int delegate(ref ) dg)
    {
        dg (sds[0]);
        return 0;
    }*/

    /*auto getIterators()
    {
        foreach(s; sds)
        {
            return s.createIterator();
        }
    }*/
}

>>>>>>> FETCH_HEAD
/**
    Empty structure only for unitttests.

struct DummySpatialStructure
{
    void getLeafs(Comp){}
}

unittest
{
    auto g0 = new Group!(DummySpatialStructure)();
    auto g1 = new Group!(DummySpatialStructure, "test")();
}
*/
/++
class Group(T...) : SceneGraphObject
{
    /// Spatial data structures
    //public RefCounted!(Tuple!(T), RefCountedAutoInitialize.no) sds;

static if (T.length == 2 && is(typeof(T[1]) : string) )
{
    bool a = true;
}else
{
    bool a = false;
}
    Tuple!(T) sds;

    alias Types =TypeTuple!(sds.Types);

    alias sds this;

    void aaa(){writeln("bbb", a);}

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
    /*auto getIterators()
    {
        foreach(s; sds)
        {
            return s.createIterator();
        }
    }*/
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
}+/
/*
class Leaf : SceneGraphObject
{
    static int a = 0;
    override void getLeafs(Comp)
    {
        writeln("Leaf", a++);
    }
}
*/

