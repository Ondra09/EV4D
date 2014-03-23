
module ev4d.scenegraph.hierarchygraph;

version(unittest)
{
	import std.stdio;
}

alias HierarchyGraph HGraph;

class HierarchyGraph(T)
{
	//alias children this;

	//alias opBinary(string op)(T)

	T leaf;

	// ma binarni operator pro tohle smysl? nejspis ne, strukturu to nemeni, potreba udelat opassign
	// kdyz nekdo zavola binarni operator pro tohle, tak by se to "melo chovat korektne" ve smyslu, ze ty objekty jsou validni uz predem (spoji dve casti (ruzneho) stromu)
	// mozna to spis zakazat tuhle moznost... rozmyslet, melo by smysl pouze pokud by byly objekty jen vlistech nebo i v uzlech jak je to ted? 
	/*HierarchyGraph[] opBinary(string op)(S rhs)
	if (is(typeof(leaf == rhs) : bool))
	{}
	HierarchyGraph[] opBinary(string op)(HierarchyGraph rhs){}
	HierarchyGraph[] opBinary(string op)(HierarchyGraph[] rhs){}

	Array opBinary(string op, Stuff)(Stuff stuff) if (op == "~")
    {
        // TODO: optimize
        Array result;
        // @@@BUG@@ result ~= this[] doesn't work
        auto r = this[];
        result ~= r;
        assert(result.length == length);
        result ~= stuff[];
        ret
	*/

	void opOpAssign(string op, Stuff)(Stuff stuff) @safe pure nothrow
	if (op == "~") 
    {
        static if (is(typeof(stuff[])))
        {
            addChild(stuff[]);
        }
        else
        {
            addChild(stuff);
        }
    }

//	opAssign
//	udelat jak ~= tak i = ... kopiruje obsah, ale musi prenastavit parenta
/*
	this() @safe pure nothrow
	{}

	~this()
	{}*/

private:

	void addChild(HierarchyGraph[] childArr) @safe pure nothrow
	{
		children ~= childArr;
		foreach (ref c; childArr)
		{
			c.parent = this;
		}
	}

	void addChild(HierarchyGraph child) @safe pure nothrow
	{
		children ~= child;
		child.parent = this;
	}


	HierarchyGraph parent = null;

	HierarchyGraph[] children;
}

unittest
{
	HierarchyGraph!float a = new HierarchyGraph!float();
	HierarchyGraph!float b = new HierarchyGraph!float();
	HierarchyGraph!float c = new HierarchyGraph!float();

	a.leaf = 23.0f;
	b.leaf = 1;
	c.leaf = -28;

	a ~= b;
	a ~= c;

	// HGraph!int ai = new HGraph();
	// TODO: vyresit toto a ~= ai; a pak virtualni dedicnost

	HierarchyGraph!float[5] hgArray;

	foreach (int i, ref hg; hgArray)
	{
		hg = new HGraph!float();
		hg.leaf = i;
	}
	
	a ~= hgArray;

	int compval = 5;

	//traverseTree!("leaf < compval","a<5")(a);
	traverseTree!("leaf < compval")(a);
}

// pred is comparing function
void traverseTree(alias pred)(HierarchyGraph!float g)
//if (is (typof(pred()) == bool))
//if (is(typeof(unaryFun!pred)))
{
	version(unittest)
	{
	writeln(g.leaf);
	}
	foreach(HierarchyGraph!float child; g.children)
	{
		version(unittest)
		{
		writeln(child.leaf);
		}
	}
/*	HierarchyGraph* _hg;

	this (in HierarchyGraph* hg, alias less = "a < b ")
	{
		_hg = hg;
	}*/
}
