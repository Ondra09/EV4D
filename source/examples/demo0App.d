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
VBO[1] vboText;

Font font; // test font

float dx = 0;
float drotz = 0;
float dy = 0;
float dz = 0;
immutable float speed = 1.1;
immutable float zanglespd = 2;


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
                drotz = zanglespd;
            }

            if (key == GLFW_KEY_S)
            {
                dy = -speed;
            }

            if (key == GLFW_KEY_D)
            {
                drotz = -zanglespd;
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
                drotz = 0;
            }

            if (key == GLFW_KEY_S)
            {
                dy = 0;
            }

            if (key == GLFW_KEY_D)
            {
                drotz = 0;
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
    float[] vertexes;
    float[] normals;
    GLubyte[] indices;

    int indicesCount = 0;

    ubyte[] color;
}

SHGraph sceneRoot;
//SHGraph fighterRotationNode;
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
    //fighterRotationNode = new SHGraph();
    fighterNode = new SHGraph();
    camNode = new SHGraph();
    lightPivot0 = new SHGraph();
    light0 = new SHGraph();

    sceneRoot = a0;

    camNode.data.translationM.translate(0.0f, 0.0f, 0.0f);

    cam.viewMatrix = &camNode.data.worldMatrix;

    // create an object for this
    a0 ~= fighterNode;
    //a0 ~= fighterRotationNode;
    //fighterRotationNode ~= fighterNode;

    //a0 ~= camNode;

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

    SHGraph[1] textSH;
    textSH[0] = font.createTextNode!(SHGraph)(vboText[0], "FPS: --", textShader, true);


    textSH[0].data.rotationM.rotatez(30.0f/180*3.1415924);
    textSH[0].data.rotationM.translate(10, 10, 0);

    uiSHroot ~= textSH;

    recomputeTransformations(uiSHroot);

    import ev4ds.grid;
    auto layers = new Layers!(SpacialObject*, "BULLET", "SHIP")();
    
    import gl3n.aabb;
    SpacialObject so;
    
    so.aabb.min = vec3(10, 10, 0);
    so.aabb.max = vec3(23.4, 14.9, 0);
    layers.layer[layers.GridNames.SHIP].insertObjectAABB(&so);

    so.aabb.min = vec3(10, 10, 0);
    so.aabb.max = vec3(11, 10, 0);
    layers.layer[layers.GridNames.SHIP].insertObjectAABB(&so);

    import std.stdio;
    writeln(layers.layer[layers.GridNames.SHIP].getObjects(300.5, 10.5));

        //
        import std.stdio;
    
        writeln("GridNames: ", layers.GridNames.max);
        //writeln(layers.layer[layers.GridNames.SHIP] );
        //writeln(layers.layer[1].gridSize );

    writeln(layers.layer[layers.GridNames.SHIP]);
    layers.layer[layers.GridNames.SHIP].clearAll();
    writeln(layers.layer[layers.GridNames.SHIP]);

    layers.layer[layers.GridNames.SHIP].insertObjectAABB(&so);
    layers.layer[layers.GridNames.SHIP].insertObjectAABB(&so);
    writeln(layers.layer[layers.GridNames.SHIP]);
    writeln(layers.layer[layers.GridNames.SHIP].getObjects(10.5, 10.5));

    SpacialObject so1;
    so1.aabb.min = vec3(0, 0, 0);
    so1.aabb.max = vec3(100, 100, 0);

    writeln("objects: ", layers.layer[layers.GridNames.SHIP].getObjects(&so1),  typeid(layers.layer[layers.GridNames.SHIP].getObjects(&so1)));

    layers.layer[layers.GridNames.SHIP].removeObject(&so);
    writeln(layers.layer[layers.GridNames.SHIP]);

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

    fighterNode.data.rotationM.rotatex(-105.0f/180*3.1415924);
    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
        lightPivot0.data.rotationM.rotatex(1.0f/180*3.1415924);


        vec4 vecx;
        vecx.x = fighterNode.data.worldMatrix[0][1];
        vecx.y = fighterNode.data.worldMatrix[1][1];
        vecx.z = fighterNode.data.worldMatrix[2][1];
        vecx.w = fighterNode.data.worldMatrix[3][1];

        vecx.normalize();

        mat4 rotM = mat4.rotation(drotz/180*3.1415924, vecx.x, vecx.y, vecx.z);

        //fighterNode.data.rotationM.rotatez(drotz/180*3.1415924);

        fighterNode.data.rotationM = rotM * fighterNode.data.rotationM ;

        fighterNode.data.translationM.translate(0, 0, dz);
        fighterNode.data.translationM.translate(dy*vecx.x, dy*vecx.y, dy*vecx.z);


        
        
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
