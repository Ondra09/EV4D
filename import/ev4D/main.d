module ev4D.main;

import std.stdio;
import ev4D.sceneGraph.group;

int main(string[] argv)
{
	writeln("Hello D-World!");

	group!int f;
	f.spatial = 7;


	getchar();
	return 0;
}
