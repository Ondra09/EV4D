//#!/usr/bin/rdmd


import std.stdio;
import std.algorithm;
import std.conv;

void main(string[] args)
{
	//writeln(args[1]);
	
	int[] arr; // = [1,2,3,4,5,6,7,8,9,10];
	arr.length = to!(ulong)(args[1]);
	//arr[0] = 1;
	//arr[] = arr[] + 1;
	
	foreach (i, val; arr)
	{
		arr[i] = cast(int)i+1;
	}
	
	writeln(arr);
	
	// a nebo jinak pry suma ctvercu se rovna 1^2 + .. n^2 - n*(n+1)*(2n+1)/6, pry indukci
	
	auto r = arr.reduce!((a,b) => a + b, (a,b) => a + b * b);
	auto r0s = r[0]*r[0];
	writefln("sum = %s, sum of squares = %s, diff: %s", r[0]*r[0], r[1], r0s - r[1]);

}
