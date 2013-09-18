
import std.stdio;

class A(T...)
{
	T _args;
	this(T args)
	{
		_args = args;
	}

	void printT()
	{
		foreach(t; _args)
		{
			writeln(t);
		}
	}
}

int main(string[] args)
{
	A!(int, float, string)a = new A!(int, float, string)(5, 5.326, "pes a kocka");
	a.printT();
	return 0;
}

