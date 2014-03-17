
module ev4d.scenegraph.hierarchygraph;

alias HierarchyGraph HGraph;

struct HierarchyGraph(T)
{
	alias children this;

	T leaf;

	HierarchyGraph* parent = null;

	HierarchyGraph[] children;

	// ma binarni operator pro tohle smysl? nejspis ne, strukturu to nemeni, potreba udelat opassign
	// kdyz nekdo zavola binarni operator pro tohle, tak by se to "melo chovat korektne" ve smyslu, ze ty objekty jsou validni uz predem (spoji dve casti (ruzneho) stromu)
	// mozna to spis zakazat tuhle moznost... rozmyslet, melo by smysl pouze pokud by byly objekty jen vlistech nebo i v uzlech jak je to ted? 
	HierarchyGraph[] opBinary(string op)(S rhs)
	if (is(typeof(leaf == rhs) : bool))
	{}
	HierarchyGraph[] opBinary(string op)(HierarchyGraph rhs){}
	HierarchyGraph[] opBinary(string op)(HierarchyGraph[] rhs){}

	opAssign
	udelat jak ~= tak i = ... kopiruje obsah, ale musi prenastavit parenta
/*
	this() @safe pure nothrow
	{}

	~this()
	{}*/


}

unittest
{
	HierarchyGraph!float a;
	assert((a ~ 1.0) ==);
	assert((a ~ 1.0f) ==);
	assert((a ~ 1));
	assert((a ~ 'c');

	a ~= 1.0;
	a ~= 1.0f;
	a ~= 1;
	a ~= 'c';

	HierarchyGraph!float b;
	assert((a ~ b) == );
	HierarchyGraph!int c;
	HierarchyGraph!char d; // this should not be working
	etc...
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
