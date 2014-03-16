
import std.stdio;

import ev4d.scenegraph.scenegraphobject;
import ev4d.scenegraph.simplespatial;
import ev4d.scenegraph.bvh;
import ev4d.scenegraph.hierarchygraph;


int main(string[] argv)
{

    HGraph!int a0;
    HGraph!int a1;

    a0.leaf = 7;
    a1.leaf = 23;

    a0.children ~= a1;

    int[] arr;
    //arr = a0.traverse();
    writeln(arr);
/++
    int[] arrb = [ 0 ];
    foreach (i; 0..100) // it grows capacity = 2*capacity+1
    {
        arrb ~= i;
        writeln(arrb.capacity);
    }+/

    getchar();
    return 0;
}

/++
int oldmain(string[] argv)
{
	writeln("Hello D-World!");

	Group!(SimpleSpatial, "dummy") g0 = new Group!(SimpleSpatial, "dummy");
    g0.sds.dummy = new SimpleSpatial();
    g0.dummy.a = 5;
    g0.aaa();
    //Array!(size_t).Payload faaa;
    //Group!(int, char) g1 = new Group!(int, char);
    //g1.sds[0] = 5;
    //g1.sds[1] = 'r';

    //g0.sds.dummy.addChild(g1);

    //g0.setTraversalCondition(true);
    
    writeln("foreach g0");
    //foreach (i, T; g0)
    //{
    //    writeln(T);
    //    writeln(T.a);
    //} 

    writeln("ffff"); 
    foreach (it; g0)
    {
        writeln(it);
    }

    Leaf lf =new Leaf();
    g0.dummy.addChild(lf);
    g0.dummy.addChild(new Leaf());

    //g0.traverseSubnodes();
    g0.getLeafs();

    g0.dummy.scale.set(4, 2, 6);
    g0.dummy.translation.set(7, 2, 3);


    writeln(g0.dummy.getTransform());

    writeln("Travrse nodes");

    BoundingVolumeHierarchy a0;
    BoundingVolumeHierarchy a1;

    a0.numero = 7;
    a1.numero = 23;

    a0.children ~= a1;

    int[] arr;
    a0.traverse(arr);
    writeln(arr);

	getchar();
	return 0;
}
+/
