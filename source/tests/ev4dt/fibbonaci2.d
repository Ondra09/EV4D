
import std.stdio;

void main()
{
	int fib0 = 1;
	int fib1 = 2;
	
	int even = 2;
	
	while (fib1 + fib0 < 4000000)
	{
		auto fib2 = fib0 + fib1;
		fib0 = fib1;
		fib1 = fib2;
		writeln(fib1);
		if ((fib2 % 2) == 0)
		{
			even+=fib1;
//			writeln(fib1);
		}
	}
	
	writeln(even);
}
