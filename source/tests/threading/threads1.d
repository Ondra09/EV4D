#!/usr/bin/rdmd
// Computes average line length for standard input.
import std.concurrency, std.stdio;

void main() {
	auto low = 0, high = 100;
	immutable int[] array = [5,5];
	spawn (&fun, low, high, array);
		foreach(i; low .. high)
	{
		writeln("main: ",i);
	}
}

void fun(int low, int high, immutable int[] array)
{
	foreach(i; low .. high)
	{
		writeln("thread: ",i);
	}
}
