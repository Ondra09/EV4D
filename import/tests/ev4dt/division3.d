
import std.stdio;
import std.math;

void main()
{
	long largeNumber = 8462696833;
	
	//better way go from zero to sqrt(largenumber) and if found divisor, use him to divide
	//number and recompute largenumber
	
	int sqL = cast(int)sqrt(cast(float)largeNumber);
	
	for (int i = sqL; i>1; --i)
	{
		if ((largeNumber % i) == 0 )
		{
			writeln(i);
			break;
		}
	}
}
