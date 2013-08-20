
import std.stdio;
import std.math;

int generatePalindrom(ref int palV)
{
	int dec = palV % 10;
	int hun = (palV / 10) % 10;
	int tous = (palV / 100) % 10;
	
	int retVal = palV*1_000 + dec * 100 + hun * 10 + tous;
	
	palV--;
	
	return retVal;
}

/*

The palindrome can be written as
11(9091a + 910b + 100c) = mn;
a,b & c being 1 digit integers and m & n being 3 digit intergers.

Let 11 * 10 < m < 11 * 90;

for(int a=9; a>=1; a--)
  for(int b=9; b>=0; b--)
    for(int c=9; c>=0; c--){
      num = 9091 * a + 910 * b + 100 * c;
      for(int divider=90; divider>=10; divider--){
        //look for divider that can divide 
        //and also doesn't make n > 999
	if((num % divider) == 0){
	  if((num / divider) > 999)
	    break;
	  else
	    result = num * 11; //Found it!
	} else { break; }
      }
*/
     
void main()
{
	int palV = 997;
	
	while( palV > 99 )
	{
		auto palindrom = generatePalindrom(palV);
		
		auto sqRoot = sqrt(cast(float)palindrom);
		
		for (int i = 999; i > sqRoot; --i)
		{
			if ((palindrom % i) == 0)
			{
				writeln("Result: ", palindrom, " divised: ", i);
				break;
			}
		}
		
		//writeln(palindrom);
	}
	
	
}
