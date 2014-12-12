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

import derelict.glfw3.glfw3;
import derelict.opengl3.gl;

import ev4d.mesh.generator;

import gl3n.linalg;

VBO vbo; // fighter
VBO vboText; // text0

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
SHGraph lightPivot0;

PointLight pointLight0;

Renderer initScene()
{
    Scene scene = new Scene();

    Renderer renderer = new Renderer();

	SHGraph camNode;
    SHGraph light0;

    Technique!(SHGraph) tech0 = new Technique!(SHGraph)();

    Camera cam = new Camera(800, 600);
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
    light0.data.translationM.translate(0, 0, -2);

    tech0.scene = a0;

    // set techniques to renderer
    renderer.techniques ~= [tech0];

    ////
    ShipMaterial!GameVertex_ simpleShader = new ShipMaterial!GameVertex_();
    fighterNode.data.material = simpleShader;

    testImport(vbo);

    fighterNode.data.vbo = &vbo;

    // lights init
    pointLight0.worldMatrix = &light0.data.worldMatrix;
    pointLight0.color = vec3(1, 1, 0);

    tech0.lights.addPointLight(&pointLight0);

    // BUG: this code causes invalid memory at applicaiton exit
    // screen space text
    Technique!(SHGraph) tech1 = new Technique!(SHGraph)();

    Camera uiCam = new Camera(800, 600);
    uiCam.createOrtho(0, 800, 0, 600, 1, 30);

    tech1.camera = uiCam;

    SHGraph uiSHroot = new SHGraph();
    uiSHroot.data.translationM.translate(0, 0, 3); // 
    tech1.scene = uiSHroot;

    uiCam.viewMatrix =  &uiSHroot.data.worldMatrix;

    renderer.techniques ~= tech1;

/*
    TODO: add material here with text rendering and create maybe helper function that creates text from
    given font, create scene node and puts it on appropriate screen loacation (transformation)
*/
    // load text file
    Font font = new Font();
    font.loadTextData("objects/OpenSans-Regular.json");

    //font.createTextVBO(vboText, "sedmero krkavců ąß∂‘’łėę€œ∑´®†¥¨ˆøπø«æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥a +ěščžýáíé");
    font.createTextVBO(vboText, "ěščžýáíé");

    TextShader!(GlyphVertex_) textShader = new TextShader!(GlyphVertex_)();
    uiSHroot.data.vbo = &vboText;
    uiSHroot.data.material = textShader;

    //recomputeTransformations(uiSHroot);

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
    //glfwWindowHint(GLFW_SAMPLES, 4);
    window = glfwCreateWindow(800, 600, "Space Shooter 1000", null, null);
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

    float translate = 0;
    float sum = 0.01;

    Renderer renderer = initScene();
    fighterNode.data.translationM = mat4.translation(0, 0.0, -1.6);

    //fighterNode.data.rotationM.rotatex(-105.0f/180*3.1415924);
    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
       	// rotate with fighter
        //fighterNode.data.rotationM.rotatex(1.0f/180*3.1415924);

        lightPivot0.data.rotationM.rotatex(1.0f/180*3.1415924);

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

        recomputeTransformations(sceneRoot); // for multiple roots? all techniques
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
