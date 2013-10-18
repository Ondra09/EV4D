import std.stdio;

template marray(T,int size)
{
    alias T[size] marray;
}

int main(string[] args)
{
    marray!(int, 5) a;
    marray!(int, 5) b;

    a[0] = 6;
    b[0] = 7;

    writeln(a[0]);
    writeln(b[0]);

    return 0;
}

