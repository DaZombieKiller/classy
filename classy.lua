--
-- Classy: a class and struct library for Lua
--
-- Copyright(C) 2016 Benjamin Moir
-- Distributed under the Boost Software License, Version 1.0.
-- (See accompanying file LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
--

-- _OBJECTS: stores classes and structs
local _OBJECTS = {}
setmetatable(_OBJECTS,
{
	__index = function(t, k)
		error("reference to undefined class or struct: " .. k)
	end,
})

-- Override type function to support custom types
local _type = type
function type(obj)
	local meta = getmetatable(obj) or {}
	if _type(meta.__type) == "string" then
		return meta.__type
	else
		return _type(obj)
	end
end

-- The name of this function can be considered misleading,
-- as it is also used to create classes in addition to structs.
-- (See the class function)
function struct(object)
	-- Check if struct/class already exists
	if rawget(_OBJECTS, object) ~= nil then
		local t = getmetatable(rawget(_OBJECTS, object)).__type
		error("redefinition of " .. t .. ": " .. object)
	end
	return function(body)
		if type(body) == "string" then
			-- Inherit from existing struct or class
			local parent = body
			local base = {}
			for k, v in pairs(_OBJECTS[parent]) do
				base[k] = v
			end
			
			-- Tell classy what the parent is
			setmetatable(base, { __parent = parent })
			
			return function(body)
				-- "Inherit" from actual body
				for k, v in pairs(body) do
					base[k] = v
				end
				
				-- Create struct
				return struct(object)(base)
			end
		elseif type(body) == "table" then
			_OBJECTS[object] = body
			local meta = getmetatable(body) or {}
			local parent = meta.__parent
			
			setmetatable(_OBJECTS[object],
			{
				__type = "struct",
				__object = object,
				__parent = parent,
				__newindex = function() end,
			})
			return object
		else
			error("struct defined with invalid or missing body: " .. object)
		end
	end
end

-- Creates a struct, and then modifies it
function class(object)
	-- Classes and structs are identical, except a class
	-- requires a constructor, while a struct does not.
	return function(body)
		if type(body) == "string" then
			-- Inherit from existing struct or class
			local parent = body
			local base = {}
			for k, v in pairs(_OBJECTS[parent]) do
				if k ~= parent then
					base[k] = v
				else
					-- Inherit constructor
					base[object] = v
				end
			end
			
			-- Tell classy what the parent is
			setmetatable(base, { __parent = parent })
			
			return function(body)
				-- "Inherit" from actual body
				for k, v in pairs(body) do
					base[k] = v
				end
				
				-- Create class
				return class(object)(base)
			end
		end
		
		if type(body[object]) ~= "function" then
			error("invalid or missing constructor in class: " .. object)
		end
		
		struct(object)(body)
		local meta = getmetatable(_OBJECTS[object])
		meta.__type = "class"
	end
end

function new(object, ...)
	-- Instantiate object
	local instance = {}
	local meta = getmetatable(_OBJECTS[object])
	for k, v in pairs(_OBJECTS[object]) do
		instance[k] = v
	end
	
	-- Does this object have a constructor?
	if type(instance[object]) == "function" then
		instance[object](instance, ...)
	end
	
	-- Attach metatable to instance
	setmetatable(instance,
	{
		__parent = meta.__parent,
		__object = meta.__object,
		__type = meta.__type,
	})
	
	return instance
end

function super(instance, method, ...)
	-- Call a method from an instance's parent object
	local meta = getmetatable(instance) or {}
	if meta.__parent == nil then
		error("object has no parent object to call from: " .. meta.__object)
	end
	return _OBJECTS[meta.__parent][method](instance, ...)
end
