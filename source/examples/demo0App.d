import std.stdio;

import ev4d.scenegraph.hierarchygraph;
import ev4d.scenegraph.simplespatial;

import ev4d.rendersystem.camera;
import ev4d.rendersystem.lights;
import ev4d.rendersystem.material;
import ev4d.rendersystem.renderer;
import ev4d.rendersystem.renderqueue;
import ev4d.rendersystem.scene;
import ev4d.rendersystem.technique;
import ev4d.rendersystem.testmaterials;
import ev4d.rendersystem.text;

// model loading handling
import ev4d.io.model;
import ev4d.io.texture;

import std.c.stdio;
import std.datetime;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl;

import ev4d.mesh.generator;

import gl3n.linalg;

VBO vbo; // fighter
VBO vboText[1];

Font font; // test font

float dx = 0;
float dy = 0;
float dz = 0;
immutable float speed = 0.1;


// TODO : read this from config file / database
immutable int windowWidth = 1024;
immutable int windowHeight = 768;

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
        {
            glfwSetWindowShouldClose(window, GL_TRUE);
        }

        if (action == GLFW_PRESS)
        {
            if (key == GLFW_KEY_A)
            {
                dx = -speed;
            }

            if (key == GLFW_KEY_S)
            {
                dy = -speed;
            }

            if (key == GLFW_KEY_D)
            {
                dx = speed;
            }

            if (key == GLFW_KEY_W)
            {
                dy = speed;
            }

            if (key == GLFW_KEY_Q)
            {
                dz = speed;
            }

            if (key == GLFW_KEY_E)
            {
                dz = -speed;
            }
        }

        if (action == GLFW_RELEASE)
        {
            if (key == GLFW_KEY_A)
            {
                dx = 0;
            }

            if (key == GLFW_KEY_S)
            {
                dy = 0;
            }

            if (key == GLFW_KEY_D)
            {
                dx = 0;
            }

            if (key == GLFW_KEY_W)
            {
                dy = 0;
            }

            if (key == GLFW_KEY_Q)
            {
                dz = 0;
            }

            if (key == GLFW_KEY_E)
            {
                dz = 0;
            }
        }
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
SHGraph lightPivot0;
SHGraph camNode;

PointLight pointLight0;

Renderer initScene()
{
    Scene scene = new Scene();

    Renderer renderer = new Renderer();

    SHGraph light0;

    Technique!(SHGraph, createSortKey!(SHGraph.DataType)) tech0 = 
                                                        new Technique!(SHGraph, createSortKey!(SHGraph.DataType))();

    Camera cam = new Camera(windowWidth, windowHeight);
    cam.createProjection(90);

    tech0.camera = cam; 

    SHGraph a0 = new SHGraph();
    fighterNode = new SHGraph();
    camNode = new SHGraph();
    lightPivot0 = new SHGraph();
    light0 = new SHGraph();

    sceneRoot = a0;

    camNode.data.translationM.translate(0.0f, 0.0f, 0.0f);

    cam.viewMatrix = &camNode.data.worldMatrix;

    // create an object for this
    a0 ~= fighterNode;
    a0 ~= camNode;

    fighterNode ~= lightPivot0;
    lightPivot0 ~= light0; 
    light0.data.translationM.translate(0, 0, -3);

    tech0.scene = a0;

    // set techniques to renderer
    renderer.techniques ~= [tech0];

    ////
    ShipMaterial!GameVertex_ simpleShader = new ShipMaterial!GameVertex_();
    fighterNode.data.material = simpleShader;

    testImport(vbo, fighterNode.data.aabb);

    fighterNode.data.vbo = &vbo;

    // lights init
    pointLight0.worldMatrix = &light0.data.worldMatrix;
    pointLight0.color = vec3(1, 1, 0.2);

    tech0.lights.addPointLight(&pointLight0);

    // screen space text + ui
    Technique!(SHGraph, createSortKey!(SHGraph.DataType)) tech1 = 
                                                        new Technique!(SHGraph, createSortKey!(SHGraph.DataType))();

    Camera uiCam = new Camera(windowWidth, windowHeight);
    uiCam.createOrtho(0, windowWidth, 0, windowHeight, 1, 30);

    tech1.camera = uiCam;

    SHGraph uiSHroot = new SHGraph();
    SHGraph orthoCamSH = new SHGraph();
    orthoCamSH.data.translationM.translate(0, 0, 2); // 
    tech1.scene = uiSHroot;
    uiSHroot ~= orthoCamSH;

    uiCam.viewMatrix =  &orthoCamSH.data.worldMatrix;

    renderer.techniques ~= tech1;

    // load text file
    font = createFont("objects/OpenSans-Regular.json");
    TextShader!(GlyphVertex_) textShader = new TextShader!(GlyphVertex_)("objects/OpenSans-Regular.png");

    SHGraph textSH[1];
    textSH[0] = font.createTextNode!(SHGraph)(vboText[0], "FPS: --", textShader, true);


    textSH[0].data.rotationM.rotatez(30.0f/180*3.1415924);
    textSH[0].data.rotationM.translate(10, 10, 0);

    uiSHroot ~= textSH;

    recomputeTransformations(uiSHroot);

    import ev4ds.grid;
    auto grid = new Grid!("AAA", "HOO")();
    

    import std.stdio;
    
        writeln("GridNames: ", grid.GridNames.sizeof);
        writeln(grid.layers[grid.GridNames.HOO] );
        writeln(grid.layers[1].gridSize );
        

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
    // glfwWindowHint(GLFW_SAMPLES, 4);
    window = glfwCreateWindow(windowWidth, windowHeight, "Demo 0", null, null);
/*
    GLint bufs, samples;
glGetIntegerv(GL_SAMPLE_BUFFERS, &bufs);
glGetIntegerv(GL_SAMPLES, &samples);
printf("MSAA: buffers = %d samples = %d\n", bufs, samples);
*/

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

    Renderer renderer = initScene();
    fighterNode.data.translationM = mat4.translation(0, 0.0, -2.6);
    // rotate with fighter
    fighterNode.data.rotationM.rotatex(90.0f/180*3.1415924);

    double timeStart = glfwGetTime();
    int frameCounter = 0;

    //fighterNode.data.rotationM.rotatex(-105.0f/180*3.1415924);
    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
        lightPivot0.data.rotationM.rotatex(1.0f/180*3.1415924);

        fighterNode.data.translationM.translate(dx, dy, dz);
        
        //
        recomputeTransformations(sceneRoot); // for multiple roots? all techniques
        renderer.render();

        /* Swap front and back buffers */
        glfwSwapBuffers(window);

        /* Poll for and process events */
        glfwPollEvents();

        frameCounter++;

        if ( (glfwGetTime()-timeStart) > 1)
        {
            timeStart = glfwGetTime();

            // 
            import std.conv;
            font.createTextVBO(vboText[0], "FPS: "~to!(string)(frameCounter), true);

            frameCounter = 0;
        }
    }
    
    //a1.data.material = null;a1.data.vbo = null;
    fighterNode = null;

    return 0;
}
