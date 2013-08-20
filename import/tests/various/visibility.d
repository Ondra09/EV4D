#!/usr/bin/rdmd

import std.concurrency, std.stdio;

shared struct SharedList
{
	shared struct Node
	{
		private int a;
		private Node * _next;

		void touch()
		{
			shared (Node) * thisNext;

			auto n = _next;
			writeln("touch");
			printf("%p\n",n);
			n = n._next;
			printf("%p\n",n);
			//writeln (n);
		}
	}
}

void main()
{
	SharedList list;

	shared (SharedList.Node) node1, node2;

	node1._next = &node2;
	node2._next = &node1;
	printf("%p %p\n", &node1, node1._next);
	//writeln(&node1, node1._next);
	
	node1.touch();

	auto fixedPointer = cast(shared(SharedList.Node)*)(cast(size_t)(&node1) | 1);
	// clearly malforemd pointer
	printf("%p %p\n", fixedPointer, fixedPointer._next);
}

