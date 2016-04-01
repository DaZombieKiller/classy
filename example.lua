--
-- Classy example file
-- Shows basic usage of Classy
--
require "classy"

class "ExampleClass"
{
	-- Class constructor
	ExampleClass = function(self)
		print "Hello, world!"
	end;
	
	-- Sample method
	MyMethod = function(self)
		print "ExampleClass MyMethod"
	end;
}

class "InheritanceExample" : ExampleClass
{
	-- Inherits all methods (including constructor) from ExampleClass
	
	MyMethod = function(self)
		print "InheritanceExample MyMethod"
	end;
}

struct "ExampleStruct"
{
	-- Structs do not require constructors, but classes do.
	-- If a struct inherits from a class, it will inherit its constructor.
	x = 0;
	y = 0;
	z = 0;
}

-- Instantiate classes, calling their constructors
local tmp1 = new "ExampleClass"
local tmp2 = new "InheritanceExample"
print()

-- Calling methods, and using super() to call methods from the parent classes
tmp1:MyMethod()
tmp2:MyMethod()
super(tmp2, "ExampleClass", "MyMethod")
print()

-- Instantiate a struct and print the values of its members
local tmp3 = new "ExampleStruct"
print("ExampleStruct defaults:")
print("x: " .. tmp3.x, "y: " .. tmp3.y, "z: " .. tmp3.z)
print()

-- Classy overrides the type() function to support custom object types
-- through the __type metamethod. You can obtain the class type and parent class types
-- via the __object and __parents metamethods, but there are no functions to automatically retrieve
-- these values by default. You would have to implement them yourself, using getmetatable()
print("tmp1 type: " .. type(tmp1))
print("tmp2 type: " .. type(tmp2))
print("tmp3 type: " .. type(tmp3))
