
import std.stdio;

import ev4d.scenegraph.simplespatial;
import ev4d.scenegraph.hierarchygraph;

import std.c.stdio;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;

extern (C) void errorcallback(int error, const char* description) nothrow
{
    //fputs(description, stderr);
    //writeln(description);
}


int main(string[] argv)
{
    DerelictGLFW3.load();
    DerelictGL3.load();

    HGraph!int a0 = new HGraph!int();
    HGraph!int a1 = new HGraph!int();
    HGraph!int a2 = new HGraph!int();

    a0.leaf = 7;
    a1.leaf = 23;
    a2.leaf = 33;

    a0 ~= a1;
    a0 ~= a2;

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

    //glfwSetErrorCallback(&errorcallback);

    /* Create a windowed mode window and its OpenGL context */
    window = glfwCreateWindow(640, 480, "Hello World", null, null);
    if (!window)
    {
        glfwTerminate();
        return -1;
    }

    /* Make the window's context current */
    glfwMakeContextCurrent(window);

    DerelictGL3.reload();

    int width, height;
    glfwGetFramebufferSize(window, &width, &height);
    glViewport(0, 0, width, height);

    immutable int vertices = 3;
    GLfloat positions[vertices*3] = [   0.5f, 0.5f, 0.0f,
                                        0.5f, -0.5f, 0.0f,
                                        -0.5f, -0.5f, 0.0f];


    CGLProgram* m_pProgram;                // Program
    CGLShader* m_pVertSh;                  // Vertex shader
    CGLShader* m_pFragSh;    

    m_pProgram = new CGLProgram();
    m_pVertSh = new CGLShader(GL_VERTEX_SHADER);
    m_pFragSh = new CGLShader(GL_FRAGMENT_SHADER);

    m_pVertSh.Load(_T("minimal.vert"));
    m_pFragSh.Load(_T("minimal.frag"));

    m_pVertSh.Compile();
    m_pFragSh.Compile();

    m_pProgram.AttachShader(m_pVertSh);
    m_pProgram.AttachShader(m_pFragSh);

    m_pProgram.BindAttribLocation(0, "in_Position");
    m_pProgram.BindAttribLocation(1, "in_Color");

    m_pProgram.Link();
    m_pProgram.Use();



    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
        /* Render here */
        glClear(GL_COLOR_BUFFER_BIT);

        glDrawArrays(GL_TRIANGLES, 0, 1);

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
