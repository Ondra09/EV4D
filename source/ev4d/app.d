
import std.stdio;

import ev4d.scenegraph.scenegraphobject;
import ev4d.scenegraph.dummystructure;

int main(string[] argv)
{
	writeln("Hello D-World!");

	Group!(DummyStructure, "dummy") g0 = new Group!(DummyStructure, "dummy");
    g0.sds.dummy = new DummyStructure();
    g0.sds.dummy.a = 5;
    //Array!(size_t).Payload faaa;
    //Group!(int, char) g1 = new Group!(int, char);
    //g1.sds[0] = 5;
    //g1.sds[1] = 'r';

    //g0.sds.dummy.addChild(g1);

    g0.setTraversalCondition(true);
    
    writeln("foreach g0");
    //foreach (i, T; g0)
    //{
    //    writeln(T);
    //    writeln(T.a);
    //} 

    writeln("ffff"); 
    foreach (it; g0)
    {
        //writeln(it);
    }

    Leaf lf =new Leaf();
    g0.dummy.addChild(lf);
    g0.dummy.addChild(new Leaf());

    //g0.traverseSubnodes();
    g0.getLeafs();

    g0.dummy.scale.set(4, 2, 6);
    g0.dummy.translation.set(7, 2, 3);


    writeln(g0.dummy.getTransform());

	getchar();
	return 0;
}

