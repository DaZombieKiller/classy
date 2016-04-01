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

function struct(object)
	-- Check if struct already exists
	if rawget(_OBJECTS, object) ~= nil then
		local t = getmetatable(rawget(_OBJECTS, object)).__type
		error("redefinition of " .. t .. ": " .. object)
	end
	
	-- Create struct
	_OBJECTS[object] = {}
	setmetatable(_OBJECTS[object],
	{
		__type     = "struct",
		__object   = object,
		__parents  = {},
	})
	
	local ft = {}
	setmetatable(ft,
	{
		__call = function(t, body, _)
			-- If inheritance is used, t is sent to the function twice
			if _ then body = _ end
			
			if type(body) == "table" then
				for k, v in pairs(body) do
					_OBJECTS[object][k] = v
				end
				
				-- Lock future modifications to struct
				getmetatable(_OBJECTS[object]).__newindex = function() end
			else
				error("struct defined with invalid or missing body: " .. object)
			end
			return object
		end,
		
		__index = function(t, parent)
			-- Inheritance
			local meta = getmetatable(_OBJECTS[object])
			table.insert(meta.__parents, parent)
			meta.__parents[parent] = true
			for k, v in pairs(_OBJECTS[parent]) do
				if k == parent then
					-- Inherit constructor
					_OBJECTS[object][object] = v
				else
					_OBJECTS[object][k] = v
				end
			end
			return ft
		end,
	})
	
	return ft
end

function class(object)
	-- Check if class already exists
	if rawget(_OBJECTS, object) ~= nil then
		local t = getmetatable(rawget(_OBJECTS, object)).__type
		error("redefinition of " .. t .. ": " .. object)
	end
	
	-- Create class
	_OBJECTS[object] = {}
	setmetatable(_OBJECTS[object],
	{
		__type     = "class",
		__object   = object,
		__parents  = {},
	})
	
	local ft = {}
	setmetatable(ft,
	{
		__call = function(t, body, _)
			-- If inheritance is used, t is sent to the function twice
			if _ then body = _ end
			
			if type(body) == "table" then
				for k, v in pairs(body) do
					_OBJECTS[object][k] = v
				end
				
				-- Lock future modifications to class
				getmetatable(_OBJECTS[object]).__newindex = function() end
			else
				error("class defined with invalid or missing body: " .. object)
			end
			
			if type(_OBJECTS[object][object]) ~= "function" then
				error("invalid or missing constructor in class: " .. object)
			end
			
			return object
		end,
		
		__index = function(t, parent)
			-- Inheritance
			local meta = getmetatable(_OBJECTS[object])
			table.insert(meta.__parents, parent)
			meta.__parents[parent] = true
			for k, v in pairs(_OBJECTS[parent]) do
				if k == parent then
					-- Inherit constructor
					_OBJECTS[object][object] = v
				else
					_OBJECTS[object][k] = v
				end
			end
			return ft
		end,
	})
	
	return ft
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
		__parents = meta.__parents,
		__object  = meta.__object,
		__type    = meta.__type,
	})
	
	return instance
end

function super(instance, parent, method, ...)
	local i_meta = getmetatable(instance)
	local p_meta = getmetatable(_OBJECTS[parent])
	
	if not i_meta.__parents[parent] then
		error(i_meta.__object .. " does not inherit from " .. p_meta.__type .. " " .. parent)
	else
		return _OBJECTS[parent][method](instance, ...)
	end
end
