
import std.stdio;

int main (string[] args)
{
	writeln(typeid(typeof("string")));
	writeln(is(typeof(string)));
	//writeln(typeid(typeof(string))); // will not compile typeof(string) is not semantically valid expression, is() returns false for that 
	// this is difference for typeof("string") that is valid
	return 0;
}

