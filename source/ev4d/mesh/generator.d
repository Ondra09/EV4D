
module ev4d.mesh.generator;

import gl3n.linalg;

/// its input range
/// emits vertexes
struct CubeVertexesEmitor(T)
{
private:
	int vertexesEmited = 0;
	T sizeX = 1;
	T sizeY = 1;
	T sizeZ = 1;
public:

	void setCubeSize(T size)
	{
		setDimensions(size, size, size);
	}

	void setDimensions(T x, T y, T z)
	{
		sizeX = x;
		sizeY = y;
		sizeZ = z;
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

        return Vector!(T, 3)(xSin * sizeX, ySin * sizeY, zSin * sizeZ) * 0.5;
    }

    void popFront()
    {
        vertexesEmited++;
    }
}

unittest
{
	// TODO
	/*
	CubeVertexesEmitor!(float) emitor;

	vec3 arrv[8];
	static float rotangle = 0;
	rotangle+=1;
	glRotatef(rotangle, 1, 1, 1);
	glBegin(GL_POINTS);
		int i = 0;
		foreach(vec3 v; emitor)
		{
			glVertex3fv(v.value_ptr);
			arrv[i] = v;
			i++;
			//writeln(v);
		}
	glEnd();
	//writeln();

	CubeTrisEmitor!(int) trisemit;

	glBegin(GL_TRIANGLES);
		foreach (Vector!(int, 3) id; trisemit)
		{
			glColor3b(cast(byte)(id.x*10), cast(byte)(id.y*10), cast(byte)(id.z*30));

			glVertex3fv(arrv[id.x].value_ptr);
			glVertex3fv(arrv[id.y].value_ptr);
			glVertex3fv(arrv[id.z].value_ptr);
		}

	glEnd();
	*/
}

struct CubeTrisEmitor(T)
{
private:
	int trisEmited = 0;
public:
	// this could be used directly as index array
	T indices[36] = [ 	0, 2, 1, 1, 2, 3,
						3, 2, 7, 7, 2, 6,
						6, 2, 4, 4, 2, 0,
						4, 0, 5, 5, 0, 1,
						5, 1, 3, 3, 7, 5,
						5, 7, 6, 5, 6, 4
					  ];

	@property bool empty() const
    {
        return trisEmited == 12;
    }

    @property Vector!(T, 3) front()
    {
    	size_t i = trisEmited * 3;
        return Vector!(T, 3)(indices[i], indices[i+1], indices[i+2]);
    }

    void popFront()
    {
        trisEmited++;
    }
}

struct CubeNormalsEmitor(T)
{
private:
	int normalsEmited = 0;
public:

	T indexes[18] = [ 	0, 0, -1,
						0, 1, 0,
						-1, 0, 0,
						0, -1, 0,
						1, 0, 0,
						0, 0, 1,
					  ];

	@property bool empty() const
    {
        return normalsEmited == 6;
    }

    @property Vector!(T, 3) front()
    {
    	size_t i = normalsEmited * 3;
        return Vector!(T, 3)(indexes[i], indexes[i+1], indexes[i+2]);
    }

    void popFront()
    {
        normalsEmited++;
    }
}
