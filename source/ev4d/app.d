import std.stdio;

import ev4d.scenegraph.hierarchygraph;
import ev4d.scenegraph.simplespatial;

import ev4d.rendersystem.camera;
import ev4d.rendersystem.material;
import ev4d.rendersystem.renderer;
import ev4d.rendersystem.renderqueue;
import ev4d.rendersystem.technique;
import ev4d.rendersystem.testmaterials;

// model loading handling
import ev4d.io.model;
import ev4d.io.texture;

import std.c.stdio;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl;

import ev4d.mesh.generator;

import gl3n.linalg;

VBO vbo; // fighter

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
struct RenderDataTest
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
SHGraph camNode1;

Renderer initScene()
{
    Renderer renderer = new Renderer();

    Technique!(SHGraph) tech0 = new Technique!(SHGraph)();
    Technique!(SHGraph) tech1 = new Technique!(SHGraph)();

    Camera cam = new Camera(640, 480, 90);
    Camera cam1 = new Camera(320, 240, 120);
    cam1.viewportX = 300;
    cam1.viewportY = 300;

    tech0.camera = cam; 
    tech1.camera = cam1;

    SHGraph a0 = new SHGraph();
    a1 = new SHGraph();
    a2 = new SHGraph();
    camNode = new SHGraph();
    camNode1 = new SHGraph();

    sceneRoot = a0;

    //a1.data.translationM.translate(0.3f, -0.5f, 0.5f);
    //a1.data.scaleM.scale(1, 1, 1);

    a2.data.translationM.translate(-1.0f, 0.5f, 0.0f);

    camNode.data.translationM.translate(0.0f, 1.0f, 1.0f);
    camNode1.data.translationM.translate(0.0f, -1.0f, 1.0f);

    cam.viewMatrix = &camNode.data.worldMatrix;
    cam1.viewMatrix = &camNode1.data.worldMatrix;

    // create an object for this
   
    SimpleMaterial!RenderDataTest smat = new SimpleMaterial!RenderDataTest();
    SimpleMaterial!RenderDataTest smat2 = new SimpleMaterial!RenderDataTest();
    
    a1.data.material = smat;
    a2.data.material = smat2;

    a0 ~= a1;
    a1 ~= a2;
    a0 ~= camNode;
    a0 ~= camNode1;

    tech0.scene = a0;
    tech1.scene = a0;

    // set techniques to renderer
    renderer.techniques ~= [tech0, tech1];

    ////
    ShipMaterial!GameVertex_ simpleShader = new ShipMaterial!GameVertex_();
    a1.data.material = simpleShader;

    testImport(vbo);

    a1.data.vbo = &vbo;

    return renderer;
}

int main(string[] argv)
{
    DerelictGLFW3.load();
    DerelictGL.load();

    //loadImageEngine();

    import derelict.assimp3.assimp;
    // Load the Assimp3 library.
    DerelictASSIMP3.load(); // should not be here pbly
    
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
    window = glfwCreateWindow(640, 480, "Space Shooter 1000", null, null);

    if (!window)
    {
        glfwTerminate();
        return -1;
    }

    /* Make the window's context current */
    debug
    {
        writeln("Crating context.");
    }
    glfwMakeContextCurrent(window);

    glfwSetKeyCallback( window, &keyCallback);

    DerelictGL.reload();
    debug
    {
        writeln("GL binding reload.");
    }

    int width, height;
    glfwGetFramebufferSize(window, &width, &height);

    float translate = 0;
    float sum = 0.01;

    Renderer renderer = initScene();

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
        if(translate > 10)
        {
            sum *= -1;
        }

        if(translate < -10)
        {
            sum *= -1;
        }

        renderer.render();

        /* Swap front and back buffers */
        glfwSwapBuffers(window);

        /* Poll for and process events */
        glfwPollEvents();
    }
    
    //a1.data.material = null;a1.data.vbo = null;

    return 0;
}
