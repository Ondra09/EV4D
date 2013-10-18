
import std.stdio;

template A(T...)
{
    private:
        int b;
    
    static if (T.length>0)
    {
        void printL()
        {
            T[0] a = 5;
            writeln(a);
            writeln(T.length);
        }
    }
}

class B(T...)
{
/*    this(T ts)
    {
        writeln(ts.length);
    }*/
    static if (T.length>0)
    {
        void printL()
        {
            //T[0] a = 5;
            //writeln(a);
            writeln("abb");
            writeln(T.length);
            foreach (t; T)
            {
                writeln(t);
            }
        }
    }else
    {
        void printL()
        {
            writeln("aab");
        }
    }

}

int main(string[] argv)
{
    A!(int, float, double).printL();
    //a.printL();
    B!(int, float, double) a = new B!(int, float, double)();
    a.printL();

    return 0;
}

