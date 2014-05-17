
import std.stdio;

import ev4d.scenegraph.hierarchygraph;
import ev4d.scenegraph.simplespatial;

import ev4d.rendersystem.camera;
import ev4d.rendersystem.material;
import ev4d.rendersystem.renderer;
import ev4d.rendersystem.renderqueue;
import ev4d.rendersystem.technique;

import std.c.stdio;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl;

import ev4d.mesh.generator;

import gl3n.linalg;

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

// pbly struct better
class RenderDataTest
{
    float vertexes[];
    float normals[];
    GLubyte indices[];

    int indicesCount = 0;

    ubyte color[];
}

SHGraph sceneRoot;

SHGraph a1;
SHGraph a2;
SHGraph camNode;

Renderer initScene()
{
    Renderer renderer = new Renderer();

    Technique!(SHGraph) tech0 = new Technique!(SHGraph)();

    Camera cam = new Camera(640, 480, 120);

    tech0.camera = cam; 

    SHGraph a0 = new SHGraph();
    a1 = new SHGraph();
    a2 = new SHGraph();
    camNode = new SHGraph();

    sceneRoot = a0;

    //a1.data.translationM.translate(0.3f, -0.5f, 0.5f);
    a1.data.scaleM.scale(2, 1, 1);

    a2.data.translationM.translate(-1.0f, 0.5f, 0.0f);

    camNode.data.translationM.translate(0.0f, 1.0f, 1.0f);

    cam.viewMatrix = &camNode.data.worldMatrix;

    RenderDataTest rdt = new RenderDataTest;
    rdt.color = [cast(ubyte)(255), 0, 0, cast(ubyte)(255)];

    RenderDataTest rdt2 = new RenderDataTest;
    rdt2.color = [cast(ubyte)(255), cast(ubyte)(255), 0, cast(ubyte)(255)];

    SimpleMaterial!RenderDataTest smat = new SimpleMaterial!RenderDataTest();
    SimpleMaterial!RenderDataTest smat2 = new SimpleMaterial!RenderDataTest();

    smat.bindData(rdt);
    smat2.bindData(rdt2);

    rdt.vertexes = new float[3 * 8];
    rdt.color = new ubyte[3 * 8];

    CubeVertexesEmitor!(float) emitor;
    int i = 0;
    foreach(vec3 v; emitor)
    {
        rdt.color[i] = cast(ubyte)(i*30);
        rdt.vertexes[i++] =  v.y;

        rdt.color[i] = cast(ubyte)(i*30);
        rdt.vertexes[i++] =  v.x;

        rdt.color[i] = cast(ubyte)(i*30);
        rdt.vertexes[i++] =  v.z;    
    }
    CubeTrisEmitor!(int) trisemit;

    rdt.indices = new GLubyte[trisemit.indices.length];
    rdt.indicesCount = trisemit.indices.length;

    foreach(int j, int idx; trisemit.indices[])
    {
        rdt.indices[j] = cast(ubyte)(idx);
    }

    rdt2.vertexes = new float[3 * 8];
    rdt2.vertexes[0] = -0.5f;
    rdt2.vertexes[1] = rdt2.vertexes[2] = 0;
    
    a1.data.material = smat;
    a2.data.material = smat2;

    a0 ~= a1;
    a1 ~= a2;
    a0 ~= camNode;

    tech0.scene = a0;

    renderer.techniques ~= tech0;

    return renderer;
}

int main(string[] argv)
{
    DerelictGLFW3.load();
    DerelictGL.load();

    Renderer renderer = initScene();
   
    // window initialization & callbacks
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

    float translate = 0;
    float sum = 0.01;

    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
        recomputeTransformations(sceneRoot);

        //sceneRoot.data.translationM = mat4.translation(-translate, 0, 0);
        //sceneRoot.data.rotationM.rotatez(-0.5f/180*3.1415924);

        

        a1.data.translationM = mat4.translation(translate, translate, 0);
        a1.data.rotationM.rotatez(5.0f/180*3.1415924);

        //
        camNode.data.translationM.translate(0, 0, sum);

        translate += sum;
        if(translate > 3)
        {
            sum *= -1;
        }

        if(translate < -3)
        {
            sum *= -1;
        }

        renderer.render();

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
