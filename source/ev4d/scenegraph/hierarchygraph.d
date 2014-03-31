
module ev4d.scenegraph.hierarchygraph;

import std.range;
import std.container;
import std.functional;

version(unittest)
{
	import std.stdio;
}

alias HierarchyGraph HGraph;

class HierarchyGraph(T)
{
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

	void opOpAssign(string op, Stuff)(Stuff stuff)//  @safe pure nothrow
	if (op == "~") 
    {
    	/+version(unittest)
		{
			writeln("Adding child.");
		}+/

    	addChild(stuff);
        /+static if (is(typeof(stuff[])))
        {
            addChild(stuff[]);
        }
        else
        {
            addChild(stuff);
        }+/
    }

//	opAssign
//	udelat jak ~= tak i = ... kopiruje obsah, ale musi prenastavit parenta
/*
	this() @safe pure nothrow
	{
		children.reserve(3);
	}

	~this()
	{}*/

	/+struct Range
	{
        @property bool empty()
        {
            assert(0);
        }

        @property T front()
        {
            assert(0);
        }

        void popFront()
        {
            assert(0);
        }
	}+/

	const bool empty()
	{
		return child.empty();
	}

 	auto children()
	{
		return child;
	}

private:

	void addChild(HierarchyGraph[] childArr)// @safe pure nothrow
	{
		foreach (ref c; childArr)
		{
			c.parent = this;
		}

		child ~= childArr;
	}

	void addChild(HierarchyGraph nchild)// @safe pure nothrow
	{
		child ~= nchild;

		child[$-1].parent = this;
	}


	HierarchyGraph parent = null;

	Array!(HierarchyGraph) child;

	//alias childthis;
	/*alias child.opSlice opSlice;
	alias child.front front;
	alias child.back back;
	alias child.Range Range;*/
	//alias child.empty empty;
}

unittest
{
	HierarchyGraph!float a = new HierarchyGraph!float();
	HierarchyGraph!float b = new HierarchyGraph!float();
	HierarchyGraph!float c = new HierarchyGraph!float();
	HierarchyGraph!float f = new HierarchyGraph!float();

	a.leaf = 23.0f;
	b.leaf = 10;
	c.leaf = 28;
	f.leaf = -1000;

	writeln("a length: ", a.children.capacity,": ", a.children.length, a.children.empty);
	
	a ~= b;
	writeln("a length: ", a.children.capacity,": ", a.children.length, a.children.empty);
	a ~= c;
	writeln("a length: ", a.children.capacity,": ", a.children.length, a.children.empty);
	c ~= f;
	writeln("a length: ", a.children.capacity,": ", a.children.length, a.children.empty);

	// HGraph!int ai = new HGraph();
	// TODO: vyresit toto a ~= ai; a pak virtualni dedicnost

	HierarchyGraph!float[6] hgArray;

	foreach (int i, ref hg; hgArray)
	{
		hg = new HGraph!float();
		hg.leaf = i + 2;
	}
	
	a ~= hgArray;

	writeln("a length: ", a.children.capacity,": ", a.children.length, a.children.empty);

	int compval = 3;

	writeln("Uninttest Traverse");
	traverseTree!("a.leaf < 10")(a);

	writeln("Uninttest Traverse second run");
	traverseTree!(b => b.leaf > compval)(a);

	writeln("Uninttest Traverse third run");
	HierarchyGraph!float finalArray[];
	traverseTree!(b => finalArray ~= b )(a);
	writeln("Items returned");
	writeln (finalArray);

	writeln("Uninttest Traverse fourth run");
	auto ff = delegate bool (HierarchyGraph!float b) 
							{ 
								if (b.parent is null)
								{
									writeln("Root");
								}else
								{
									writeln(b.parent.leaf,"<=", b.leaf);
								}
								 return true; 
							};

	traverseTree!(ff)(a);

	writeln("Post order traversal");
	f = new HierarchyGraph!float();
	f.leaf = 20;
	c ~= f;
	f = new HierarchyGraph!float();
	f.leaf = 21;
	c ~= f;
	f = new HierarchyGraph!float();
	f.leaf = 22;
	hgArray[1] ~= f;
	b = f = new HierarchyGraph!float();
	f.leaf = 23;
	hgArray[1] ~= f;
	f = new HierarchyGraph!float();
	f.leaf = 24;
	hgArray[1] ~= f;
	f = new HierarchyGraph!float();
	f.leaf = 25;
	hgArray[3] ~= f;

	f = new HierarchyGraph!float();
	f.leaf = 26;
	hgArray[3] ~= f;

	f = new HierarchyGraph!float();
	f.leaf = 27;
	b ~= f;
	f = new HierarchyGraph!float();
	f.leaf = 28;
	b ~= f;
	f = new HierarchyGraph!float();
	f.leaf = 29;
	b ~= f;

	

	traverseTree!("true", TreeTraversalOrder.POST_ORDER)(a);
}

enum TreeTraversalOrder
{
	PRE_ORDER,
	POST_ORDER
}

/**
	
*/
// pred is comparing function
void traverseTree(alias pred, TreeTraversalOrder order = TreeTraversalOrder.PRE_ORDER, T)(T g)
if (is(typeof(unaryFun!pred)))
//if (is (typof(pred()) == bool))
{
	alias unaryFun!(pred) predFun;

	Array!(T) buffer;

	static if (order == TreeTraversalOrder.PRE_ORDER)
	{
		buffer ~= g;
		while (!buffer.empty)
		{
			auto currentItem = buffer.back();
			buffer.removeBack();

			if (predFun(currentItem))
			{
				buffer ~= currentItem.children;

				version(unittest)
				{
					writeln(currentItem.leaf);
				}
			}
		}
	}

	static if (order == TreeTraversalOrder.POST_ORDER)
	{
		T prev = null;
		buffer ~= g;

		while (!buffer.empty)
		{
			auto currentItem = buffer.back();

			if (currentItem.children().empty) // trivialy remove item
			{
				buffer.removeBack();
				writeln(currentItem.leaf);
			}
			else // not empty need to investigate if expand or remove
			{
				if (prev == currentItem.children[0]) // we are going upwards in tree
				{
					buffer.removeBack();
					writeln(currentItem.leaf);
				}
				else // first time visited, expand item
				{
					buffer ~= currentItem.children;
				}

			}

			prev = currentItem;
		}

	}
	
	/*foreach(T child; g.children())
	{
		if (predFun(child))
		{
			version(unittest)
			{
				writeln(child.leaf);
			}
		}
	}
*/
/*	HierarchyGraph* _hg;

	this (in HierarchyGraph* hg, alias less = "a < b ")
	{
		_hg = hg;
	}*/
}
