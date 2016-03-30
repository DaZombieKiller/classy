## Classy - a C++ class/struct library for Lua
----
### Classy provides a C++ esque class and struct implementation for Lua, offering the following syntax:

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
    
    struct "ExampleStruct"
    {
    	-- Structs do not require constructors, but classes do.
    	-- If a struct inherits from a class, it will inherit its constructor.
    	x = 0;
    	y = 0;
    	z = 0;
    }

See the included example file for a more detailed look at Classy.
