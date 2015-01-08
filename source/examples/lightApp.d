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
VBO vboText[6];

Font font; // test font

float dx = 0;
float dy = 0;
float dz = 0;
immutable float speed = 0.1;

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

    Camera cam = new Camera(1024, 768);
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

    Camera uiCam = new Camera(1024, 768);
    uiCam.createOrtho(0, 1024, 0, 768, 1, 30);

    tech1.camera = uiCam;

    SHGraph uiSHroot = new SHGraph();
    SHGraph orthoCamSH = new SHGraph();
    orthoCamSH.data.translationM.translate(0, 0, 2); // 
    tech1.scene = uiSHroot;
    uiSHroot ~= orthoCamSH;

    uiCam.viewMatrix =  &orthoCamSH.data.worldMatrix;

    renderer.techniques ~= tech1;

/*
    TODO: add material here with text rendering and create maybe helper function that creates text from
    given font, create scene node and puts it on appropriate screen loacation (transformation)
*/
    // load text file
    font = createFont("objects/OpenSans-Regular.json");
    TextShader!(GlyphVertex_) textShader = new TextShader!(GlyphVertex_)("objects/OpenSans-Regular.png");

    SHGraph textSH[6];
    textSH[0] = font.createTextNode!(SHGraph)(vboText[0], "sedmero krkavců ∑´®†¥¨ˆøπø«æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥a +ěščžýáíé", textShader, true);
    textSH[1] = font.createTextNode!(SHGraph)(vboText[1], "ěščžýáíé", textShader);
    textSH[2] = font.createTextNode!(SHGraph)(vboText[2], "{}!@#$%^&*()_+", textShader);
    textSH[3] = font.createTextNode!(SHGraph)(vboText[3], "ddsf dsfdfs dsf", textShader);
    textSH[4] = font.createTextNode!(SHGraph)(vboText[4], "ç√∫˜µåß∂ƒ©˙∆!1!", textShader);
    textSH[5] = font.createTextNode!(SHGraph)(vboText[5], "**&^$%^&*", textShader);


    textSH[0].data.rotationM.rotatez(30.0f/180*3.1415924);
    textSH[1].data.rotationM.translate(100, 100, 0);
    
    textSH[2].data.rotationM.rotatez(-70.0f/180*3.1415924);
    textSH[2].data.rotationM.translate(230, 133, 0);

    textSH[3].data.rotationM.translate(330, 533, 0);
    textSH[4].data.rotationM.translate(30, 533, 0);
    textSH[5].data.rotationM.translate(630, 333, 0);

    uiSHroot ~= textSH;

    recomputeTransformations(uiSHroot);

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
    window = glfwCreateWindow(800, 600, "Shaders test ", null, null);
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
    fighterNode.data.translationM = mat4.translation(0, 0.0, -2.6);
    //camNode.data.translationM.translate(1, 0, 1);

    double timeStart = glfwGetTime();
    int frameCounter = 0;

    //fighterNode.data.rotationM.rotatex(-105.0f/180*3.1415924);
    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
       	// rotate with fighter
        //fighterNode.data.rotationM.rotatey(1.0f/180*3.1415924);

        lightPivot0.data.rotationM.rotatex(1.0f/180*3.1415924);
        //fighterNode.data.translationM = mat4.translation(0, 0.0, -2.6+translate);

        fighterNode.data.translationM.translate(dx, dy, dz);
        
        translate += sum;

        if(translate > 7)
        {
            sum *= -1;
        }

        if(translate < -7)
        {
            sum *= -1;
        }

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
            //writeln("FPS: ",frameCounter);
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
