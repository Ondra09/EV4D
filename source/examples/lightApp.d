import std.stdio;

import ev4d.scenegraph.hierarchygraph;
import ev4d.scenegraph.simplespatial;

import ev4d.rendersystem.camera;
import ev4d.rendersystem.material;
import ev4d.rendersystem.renderer;
import ev4d.rendersystem.renderqueue;
import ev4d.rendersystem.technique;
import ev4d.rendersystem.testmaterials;

import ev4d.rendersystem.scene;

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

SHGraph fighterNode;

Renderer initScene()
{
    Scene scene = new Scene();

    Renderer renderer = new Renderer();

	SHGraph camNode;

    Technique!(SHGraph) tech0 = new Technique!(SHGraph)();

    Camera cam = new Camera(640, 480, 90);

    tech0.camera = cam; 

    SHGraph a0 = new SHGraph();
    fighterNode = new SHGraph();
    camNode = new SHGraph();

    sceneRoot = a0;

    camNode.data.translationM.translate(0.0f, 0.0f, 0.0f);

    cam.viewMatrix = &camNode.data.worldMatrix;

    // create an object for this
    a0 ~= fighterNode;
    a0 ~= camNode;

    tech0.scene = a0;

    // set techniques to renderer
    renderer.techniques ~= [tech0];

    ////
    ShipMaterial!GameVertex_ simpleShader = new ShipMaterial!GameVertex_();
    fighterNode.data.material = simpleShader;

    testImport(vbo);

    fighterNode.data.vbo = &vbo;

    return renderer;
}

int main(string[] argv)
{
    DerelictGLFW3.load();
    DerelictGL.load();

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
    fighterNode.data.translationM = mat4.translation(0, 0.0, -1.5);
    fighterNode.data.rotationM.rotatex(-105.0f/180*3.1415924);
    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
    

       	// rotate with fighter
        fighterNode.data.rotationM.rotatex(2.0f/180*3.1415924);

        //
        //camNode.data.translationM.translate(0, 0, sum);

        translate += sum;
        if(translate > 10)
        {
            sum *= -1;
        }

        if(translate < -10)
        {
            sum *= -1;
        }
        
        recomputeTransformations(sceneRoot);
        renderer.render();

        /* Swap front and back buffers */
        glfwSwapBuffers(window);

        /* Poll for and process events */
        glfwPollEvents();
    }
    
    //a1.data.material = null;a1.data.vbo = null;
    fighterNode = null;

    return 0;
}
