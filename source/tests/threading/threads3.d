#!/usr/bin/rdmd
// Computes average line length for standard input.
import std.concurrency, std.stdio, std.exception;

void main() {
	auto low = 0, high = 100;
	shared int[] array = [5,5];

	auto tid = spawn(&writer);


	writeln("main:");

	tid.send(thisTid, array);
	//tid.send(thisTid, 1);
	writeln("message sent");
	enforce(receiveOnly!Tid() == tid);

	foreach (i; array)
	{
		writeln(i);
	}
}

void writer()
{
	writeln("awaiting array");
	auto msg = receiveOnly!(Tid, shared int[])();
	//auto msg = receiveOnly!(Tid, int)();
	writeln("received array");
	 writeln("Secondary thread: ");
	 msg[1][0] = 7;
	 msg[0].send(thisTid);
}
