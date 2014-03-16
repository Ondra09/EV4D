
module ev4d.scenegraph.hierarchygraph;

alias HierarchyGraph HGraph;

struct HierarchyGraph(T)
{
	alias children this;

	T leaf;

	HierarchyGraph* parent = null;

	HierarchyGraph[] children;
/*
	this() @safe pure nothrow
	{}

	~this()
	{}*/


}

alias HierarchyGraphIterator HGraphIterator;

// pred is comparing function
struct HierarchyGraphIterator(alias pred)
//if (is (typof(pred()) == bool))
if (is(typeof(unaryFun!pred)))
{
/*	HierarchyGraph* _hg;

	this (in HierarchyGraph* hg, alias less = "a < b ")
	{
		_hg = hg;
	}*/
}
