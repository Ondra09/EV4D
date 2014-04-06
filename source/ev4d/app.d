
import std.stdio;

import ev4d.scenegraph.simplespatial;

import ev4d.rendersystem.rendertarget;

import std.c.stdio;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl;



extern (C) nothrow 
{
    void errorCallback(int error, const (char)* description)
    {
        //fputs(description, stderr);

        printf("%d:, %s", error, description);
    }

    void keyCallback(GLFWwindow* window, int key, int scancode, int action, int mods)
    {
        if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
            glfwSetWindowShouldClose(window, GL_TRUE);
    }
}

int main(string[] argv)
{
    DerelictGLFW3.load();
    DerelictGL.load();

    SHGraph a0 = new SHGraph();
    SHGraph a1 = new SHGraph();
    SHGraph a2 = new SHGraph();

    a1.data.translationM.translate(0.3f, -0.2f, 0.5f);
    a2.data.translationM.translate(0, -0.2f, 0.5f);

    a0 ~= a1;
    a0 ~= a2;

    RenderTarget!SHGraph rt0 = new RenderTarget!SHGraph();
    rt0.scene = a0;

    GLFWwindow* window;

    /* Initialize the library */
    if (!glfwInit())
    {
        return -1;
    }

    scope (exit)
    {
        glfwTerminate();
    }

    glfwSetErrorCallback(&errorCallback);

    /* Create a windowed mode window and its OpenGL context */
    window = glfwCreateWindow(640, 480, "Hello World", null, null);
    if (!window)
    {
        glfwTerminate();
        return -1;
    }

    /* Make the window's context current */
    glfwMakeContextCurrent(window);

    glfwSetKeyCallback( window, &keyCallback);

    DerelictGL.reload();

    int width, height;
    glfwGetFramebufferSize(window, &width, &height);
    glViewport(0, 0, width, height);

    const int vertices = 3;
    GLfloat positions[vertices*2] = [  1, 1,
                                       -1, 1, 
                                       1, -1];

    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, &positions);

    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
        /* Render here */
        glClear(GL_COLOR_BUFFER_BIT);
        glViewport(0, 0, width/2, height/2);

        glColor3f(1.0f, 0.0f, 0.0f);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        glViewport(width/2, height/2, width/2, height/2);
        glColor3f(1.0f, 1.0f, 0.0f);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        /* Swap front and back buffers */
        glfwSwapBuffers(window);

        /* Poll for and process events */
        glfwPollEvents();
    }

    return 0;

    //traverseTree!("leaf < compval")(a0);

/++
    int[] arrb = [ 0 ];
    foreach (i; 0..100) // it grows capacity = 2*capacity+1
    {
        arrb ~= i;
        writeln(arrb.capacity);
    }+/
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
    g0.getLeafs((sc => 1>0 ) );

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
