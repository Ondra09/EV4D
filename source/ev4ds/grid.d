/**
 Authors: Eastern Wolf
 */


module ev4ds.grid;

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
class Grid(int GridSize)
{
	Layer[GridSize] layers;

	this()
	{
		foreach (l; layers)
		{
			//l = new Layer();
			l.gridSize  = defautlGridSize;
			import std.stdio;
			writeln ("layer: ", l);
		}
	}
}

/**
*/
struct Layer
{
private:
	size_t gridSize_;
public:
	

	@property
	size_t gridSize() pure nothrow @safe
					{ return gridSize_; }

	@property
	size_t gridSize(size_t size) pure nothrow @safe
					{ return gridSize_ = size; }

}
