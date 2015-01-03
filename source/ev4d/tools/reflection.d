module ev4d.tools.reflection;

/**
	Function generate list of children classes of T class. Search is recursive.
	Every children class is unique id assigned, starting from 0.

	Note: 
		Uses ModuleInfo that is undocumented and available only in runtime. 
		For that reason no code generation available with this class.
		!!!Does not work for templates!!!
	Params:
		T template parameter where class name must be insert
	Example:
	---
		class A
		{
			;
		}
		class B : A{}
		class C : B{}
		int result[string] = generateMapOfChildrenClassesWithID(A)();
		writeln(result);

		// output: ["ModuleInfo.B":0, "ModuleInfo.C":1]
	---
*/
int[string] generateMapOfChildrenClassesWithID(T)()
{
	int result[string];

	int counter = 0;
	foreach(mod; ModuleInfo)
	{
		foreach(cla; mod.localClasses)
		{
		  	auto base = cla.base;
		  	while (base)
		  	{
		  		if (base is T.classinfo)
			  	{
			  		result[cla.name] = counter; 
			  		counter++;
			  	}

			  	base = base.base;
		  	}
		}
	}

	return result;
}

/**
	Registers string and return same ID for it everytime if lookUpTable remains same for all calls.
	Primary used for unique class IDs.

	Params:
	string clsssID obtained by typeid or .classinfo.toString()
	string[] lookUpTable table where to store intemediate results
*/
ptrdiff_t getIDForKey(string classID, ref string[] lookUpTable)
{
    import std.algorithm;
    //auto classTypeString = ClassType.stringof;

	auto classTypeString = classID;    
    ptrdiff_t result = countUntil(lookUpTable, classTypeString);
    if (result == -1) 
    {
        lookUpTable ~= classTypeString;
        result = lookUpTable.length - 1;
    }
    return result;
}
