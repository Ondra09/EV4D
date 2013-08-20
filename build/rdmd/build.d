// Based on Derelict3

module ev4d;

import std.stdio : writefln, writeln;
import std.process : shell, ErrnoException;
import std.file : dirEntries, SpanMode;
import std.array : endsWith;
import std.string : format, toUpper, capitalize;

// Output configuration
enum outdir = "../lib/";
enum MajorVersion = "0";
enum MinorVersion = "1";
enum BumpVersion  = "0";
enum FullVersion  = MajorVersion ~"."~ MinorVersion ~"."~ BumpVersion;
version(Windows)
{
    enum prefix = "";
    version(Shared) enum extension = ".dll";
    else enum extension = ".lib";
}
else version(Posix)
{
    enum prefix = "lib";
    version(Shared) enum extension = ".so";
    else enum extension = ".a";
}
else
{
    static assert(false, "Unknown operating system.");
}

// Compiler configuration
version(DigitalMars)
{
    version(Shared)
        static assert(false, "Shared library support is not yet available with DMD.");

    pragma(msg, "Using the Digital Mars DMD compiler.");
    enum compilerOptions = "-lib -O -release -inline -property -w -wi";
    string buildCompileString(string files, string libName)
    {
        return format("dmd %s -I../import -of%s%s", compilerOptions, outdir, libName, files);
    }
}
else version(GNU)
{
    pragma(msg, "Using the GNU GDC compiler.");
    version(Shared)
        enum compilerOptions = "-s -O3 -Wall -shared";
    else
        enum compilerOptions = "-s -O3 -Wall";
    string buildCompileString(string files, string libName)
    {
        version(Shared)
            return format("gdc %s -Xlinker -soname=%s.%s -I../import -o %s%s.%s %s", compilerOptions, libName,MajorVersion, outdir, libName, FullVersion, files);
        else
            return format("gdc %s -I../import -o %s%s %s", compilerOptions, outdir, libName, files);
    }
}
else version(LDC)
{
    pragma(msg, "Using the LDC compiler.");
    version(Shared) enum compilerOptions = "-shared -O -release -enable-inlining -property -w -wi";
    else enum compilerOptions = "-lib -O -release -enable-inlining -property -w -wi";
    string buildCompileString(string files, string libName)
    {
        version(Shared)
            return format("ldc2 %s -soname=%s.%s -I../import -of%s%s.%s %s", compilerOptions, libName, MajorVersion, outdir, libName, FullVersion, files);
        else
            return format("ldc2 %s -I../import -of%s%sEV4D%s%s %s", compilerOptions, outdir, prefix, packageName, extension, files);
    }
}
else
{
    static assert(false, "Unknown compiler.");
}

// Package names
enum packTest = "Test";

// Source paths
enum srcEV4D = "../import/EV4D/";
enum srcTest = srcEV4D ~ "test/";

// Map package names to source paths.
string[string] pathMap;

static this()
{
    // Initializes the source path map.
    pathMap =
    [
        packTest : srcTest
    ];
}

int main(string[] args)
{
    if(args.length == 1)
        buildAll();
    else
        buildSome(args[1 .. $]);

    return 0;
}

// Build all libraries.
void buildAll()
{
    writeln("Building all packages.");
    try
    {
        foreach(key; pathMap.keys)
            buildPackage(key);
    }
    // Eat any ErrnoException. The compiler will print the right thing on a failed build, no need
    // to clutter the output with exception info.
    catch(ErrnoException e) {}
}

// Build only the packages specified on the command line.
void buildSome(string[] args)
{
    bool buildIt(string s)
    {
        if(s in pathMap)
        {
            buildPackage(s);
            return true;
        }
        return false;
    }

    try
    {
        // If any of the args matches a key in the pathMap, build
        // that package.
        foreach(s; args)
        {
            if(!buildIt(s))
            {
                s = s.toUpper();
                if(!buildIt(s))
                {
                    s = s.capitalize();
                    if(!buildIt(s))
                        writefln("Unknown package '%s'", s);
                }
            }
        }
    }
    catch(ErrnoException e) {}
}

void buildPackage(string packageName)
{
    writefln("Building EV4D%s", packageName);
    writeln();

    // Build up a string of all .d files in the directory that maps to packageName.
    string joined;
    auto p = pathMap[packageName];
    foreach(string s; dirEntries(pathMap[packageName], SpanMode.breadth))
    {
        if(s.endsWith(".d"))
        {
            writeln(s);
            joined ~= " " ~ s;
        }
    }

    string libName = format("%s%s%s%s", prefix, "EV4D", packageName, extension);
    string arg = buildCompileString(joined, libName);

    string s = shell(arg);
    writeln(s);
    writeln("Build succeeded.");
}
