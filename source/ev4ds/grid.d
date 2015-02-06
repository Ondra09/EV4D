/**
 Authors: Eastern Wolf
 */


module ev4ds.grid;

import std.typetuple;
import std.traits;
/**
	Simple module spacial hashing, grid and simple detection collision.
	2D grid.
*/

// uniform in both directions 2^gridSize
immutable size_t defautlGridSize = 4;

/**
	2D grid definition.
	Grid contains multiple layers. One can control what layer interacts with which.
*/
// put named enums maybe as templeta parameter here
class Grid(names...)
//if (allSatisfy!(isSomeString, names))
{
	Layer[names.length] layers;

	static string generateEnum(names...)()
	{
		string res = "enum GridNames{";
		foreach (f; names)
		{
			res ~= f;
			res ~= ",";
		}
		res ~= "}";
		return res;
	}

	mixin(generateEnum!(names)());
	
	this()
	{
		foreach (ref l; layers)
		{
			l.gridSize  = defautlGridSize;
			import std.stdio;
			writeln ("layer: ", l);
		}
	}
}

/**
	Single layer uesed by Grid fro better granularity or stored objets.
*/
struct Layer
{
private:
	size_t gridSize_;
	object[Tuple()] hashMap;

public:
	

	@property
	size_t gridSize() pure nothrow @safe
					{ return gridSize_; }

	@property
	size_t gridSize(size_t size) pure nothrow @safe
					{ return gridSize_ = size; }

	auto hash(float x, float y)
	{
		return Tuple!(x/gridSize_, y /gridSize_);
	}

}
