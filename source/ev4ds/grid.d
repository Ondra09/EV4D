/**
 Authors: Eastern Wolf
 */


module ev4ds.grid;

import std.typetuple;
import std.typecons;
import std.traits;
import algo = std.algorithm;

import gl3n.aabb;

import std.experimental.logger;

/**
	Simple module spacial hashing, grid and simple detection collision.
	2D grid.
*/

// uniform in both directions 2^gridSize
immutable size_t defautlGridSize = 4;

/**
	2D layers definition.
*/
// put named enums maybe as templeta parameter here

class Layers(Spatial, names...)
//if (allSatisfy!(isSomeString, names))
{
	HashGrid!(Spatial)[names.length] layer;

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
		foreach (ref l; layer)
		{
			l.gridSize  = defautlGridSize;
			import std.stdio;
			log ("layer: ", l);
		}
	}
}


/**
	Spatial Hashing Grid defintion.
	http://www.gamedev.net/page/resources/_/technical/game-programming/spatial-hashing-r2697
*/
struct HashGrid(Spatial)
{
private:
	size_t gridSize_ = defautlGridSize;
	Spatial[][Tuple!(int, int)] hashMap;

public:
	@property
	size_t gridSize() pure nothrow @safe
	{ return gridSize_; }

	@property
	size_t gridSize(size_t size) pure nothrow @safe
	{ return gridSize_ = size; }

	Tuple!(int, int) hash(float x, float y)
	{
		return tuple(cast(int)(x/gridSize_), cast(int)(y/gridSize_));
	}

	/// Inserts Spatial object into map
	void insertObjectAABB(Spatial spatial)
	{
		// z-ignored here
		auto minT = hash(spatial.aabb.min.x, spatial.aabb.min.y);
		auto maxT = hash(spatial.aabb.max.x, spatial.aabb.max.y);

		foreach (xx; minT[0]..maxT[0]+1)
		{
			foreach(yy; minT[1]..maxT[1]+1)
			{
				// TODO : use http://dlang.org/phobos/std_array.html#.Appender
				hashMap[tuple(xx,yy)] ~= spatial;
			}
		}
	}

	/**
		Retrieves objects in same cell as objects on x, y.
		Params:
			x coord of object, y coord of object
		Returns:
			all objects in same grid as x,y

	*/
	Spatial[] getObjects(float x, float y)
	{
		Spatial[] retVal;
		auto tuple = hash(x, y);
		auto objects = (tuple in hashMap);

		if (objects)
		{
			retVal = *objects;
		}

		return retVal;
	}

	/**
		Retrieves objects in same cells as Spatial with AABB.
		And removes duplicities. Firstly sort array and than call uniq.

		Params:
			spatial objects that has AABB
		Returns:
			all objects in same grids

	*/
	auto getObjects(const Spatial spatial)
	{
		Spatial[] accumVal;

		auto minT = hash(spatial.aabb.min.x, spatial.aabb.min.y);
		auto maxT = hash(spatial.aabb.max.x, spatial.aabb.max.y);

		foreach (xx; minT[0]..maxT[0]+1)
		{
			foreach(yy; minT[1]..maxT[1]+1)
			{
				auto objects = (tuple(xx, yy) in hashMap);

				if (objects)
				{
					accumVal ~= * objects;
				}
			}
		}

		auto retVal = algo.uniq(algo.sort(accumVal));
		return retVal;
	}

	/// clears hashmap content and all nodes (key-value pairs) from hash map
	void clearAll()
	{
		foreach (ref bucket; hashMap)
		{
			bucket.length = 0;
		}

		foreach (key; hashMap.keys) // taking copy of keys
		{
       		hashMap.remove(key);
   		}
	}

	/// removes given object from the whole map
	void removeObject(const Spatial obj)
	{
		foreach (ref bucket; hashMap)
		{
			auto slice = algo.remove!(a => a == obj)(bucket);
			bucket.length = slice.length; // not sure if this is proper way
		}
	}
}

unittest
{
	/*
	import gl3n.aabb;
    struct SpacialObjectDebug
    {
    	AABB aabb;
    }

    import ev4ds.grid;
    auto layers = new Layers!(SpacialObjectDebug, "BULLET", "SHIP")();
    
    import gl3n.aabb;
    SpacialObjectDebug so;
    
    so.aabb.min = vec3(0, 0, 0);
    so.aabb.max = vec3(23.4, 14.9, 0);
    layers.layer[layers.GridNames.SHIP].insertObjectAABB(so);

    so.aabb.min = vec3(10, 10, 0);
    so.aabb.max = vec3(11, 10, 0);
    layers.layer[layers.GridNames.SHIP].insertObjectAABB(so);

    import std.stdio;
    writeln(layers.layer[layers.GridNames.SHIP].getObjects(300.5, 10.5));

        //
        import std.stdio;
    
        writeln("GridNames: ", layers.GridNames.max);
        //writeln(layers.layer[layers.GridNames.SHIP] );
        //writeln(layers.layer[1].gridSize );

    writeln(layers.layer[layers.GridNames.SHIP]);
    layers.layer[layers.GridNames.SHIP].clearAll();
    writeln(layers.layer[layers.GridNames.SHIP]);
    layers.layer[layers.GridNames.SHIP].insertObjectAABB(so);
    layers.layer[layers.GridNames.SHIP].insertObjectAABB(so);
    writeln(layers.layer[layers.GridNames.SHIP]);

    layers.layer[layers.GridNames.SHIP].removeObject(so);
    writeln(layers.layer[layers.GridNames.SHIP]);
    */
}
