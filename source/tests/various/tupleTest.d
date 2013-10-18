
import std.stdio;

int main (string[] args)
{
    writeln(is(typeof("fff"): string)); // writes true
    writeln(is(typeof(string))); // writes false

    return 0;
}

