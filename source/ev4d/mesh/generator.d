
module ev4d.mesh.generator;

import gl3n.linalg;

/// its input range
/// emits vertexes
struct CubeVertexesEmitor(T)
{
private:
	int vertexesEmited = 0;
public:
	T size = 0.5;

	this(T cubeWidth = 1)
	{
		size = cubeWidth;
	}

	@property bool empty() const
    {
        return vertexesEmited == 8;
    }

    @property Vector!(T, 3) front()
    {
    	int xSin = (vertexesEmited & 1) * 2 - 1;
    	int ySin = (vertexesEmited & 2) - 1; // *2/2 - 1
    	float zSin = ((vertexesEmited & 4) * 0.5 - 1); // *2/4 - 1 

        return Vector!(T, 3)(xSin, ySin, zSin) * size * 0.5;
    }

    void popFront()
    {
        vertexesEmited++;
    }
}

struct CubeTrisEmitor(T)
{
private:
	int trisEmited = 0;
public:
	// this could be used directly as index array
	T indexes[36] = { 	(0, 2, 1), (1, 2, 3),
						(3, 2, 7), (7, 2, 6),
						(6, 2, 4), (4, 2, 0),
						(4, 0, 5), (5, 0, 1),
						(5, 1, 3), (3, 7, 5),
						(5, 7, 6), (5, 6, 4)
					  };

	@property bool empty() const
    {
        return vertexesEmited == 12;
    }

    @property Vector!(T, 3) front()
    {
    	size_t i = trisEmited * 3;
        return Vector!(T, 3)(indexes[i], indexes[i+1], indexes[i+2]);
    }

    void popFront()
    {
        trisEmited++;
    }
}

struct CubeNormalsEmitor
{

}
