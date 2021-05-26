-- Licensed under the MIT License. Written by Lars Mueller aka LMD or appguru(eu).



local function file_exists(filename)
	local file = io.open(filename, "r")
	if file == nil then return false end
	file:close()
	return true
end

local function table_flip(table)
	local flipped = {}
	for key, value in pairs(table) do
		flipped[value] = key
	end
	return flipped
end



mobs_exp.lua_log_file = {}
local files = {}
local metatable = {__index = mobs_exp.lua_log_file}

function mobs_exp.lua_log_file.new(file_path, root)
	local self = setmetatable({file_path = assert(file_path), root = root}, metatable)
	if minetest then
		files[self] = true
	end
	return self
end

function mobs_exp.lua_log_file:load()
	-- Bytecode is blocked by the engine
	local read = assert(loadfile(self.file_path))
	-- math.huge is serialized to inf
	local env = {inf = math.huge}
	setfenv(read, env)
	read()
	env.R = env.R or {{}}
	self.reference_count = #env.R
	self.root = env.R[1]
	self.references = table_flip(env.R)
end

function mobs_exp.lua_log_file:open()
	self.file = io.open(self.file_path, "a+")
end

function mobs_exp.lua_log_file:init()
	if file_exists(self.file_path) then
		self:load()
		self:_rewrite()
		self:open()
		return
	end
	self:open()
	self.root = {}
	self:_write()
end

function mobs_exp.lua_log_file:log(statement)
	self.file:write(statement)
	self.file:write"\n"
end

function mobs_exp.lua_log_file:flush()
	self.file:flush()
end

function mobs_exp.lua_log_file:close()
	self.file:close()
	self.file = nil
	files[self] = nil
end

if minetest then
	minetest.register_on_shutdown(function()
		for self in pairs(files) do
			self:rewrite() --Prevents an issue with infinite recursion. TODO: Ask LMD about it later.
			self.file:close()
		end
	end)
end

function mobs_exp.lua_log_file:_dump(value, is_key)
	if value == nil then
		return "nil"
	end
	if value == true then
		return "true"
	end
	if value == false then
		return "false"
	end
	if value ~= value then
		-- nan
		return "0/0"
	end
	local _type = type(value)
	if _type == "number" then
		return ("%.17g"):format(value)
	end
	local reference = self.references[value]
	if reference then
		return "R[" .. reference .."]"
	end
	reference = self.reference_count + 1
	local key = "R[" .. reference .."]"
	local formatted
	if _type == "string" then
		if is_key and value:len() <= key:len() and value:match"[%a_][%a%d_]*" then
			-- Short key
			return value, true
		end
		formatted = ("%q"):format(value)
		if formatted:len() <= key:len() then
			-- Short string
			return formatted
		end
	elseif _type == "table" then
		local entries = {}
		for _, value in ipairs(value) do
			table.insert(entries, self:_dump(value))
		end
		local tablelen = #value
		for key, value in pairs(value) do
			if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > tablelen then
				local dumped, short = self:_dump(key, true)
				table.insert(entries, (short and dumped or ("[" .. dumped .. "]")) .. "=" .. self:_dump(value))
			end
		end
		formatted = "{" .. table.concat(entries, ";") .. "}"
	else
		error("unsupported type: " .. _type)
	end
	self.reference_count = reference
	self.references[value] = reference
	self:log(key .. "=" .. formatted)
	return key
end

function mobs_exp.lua_log_file:set(table, key, value)
	table[key] = value
	if not self.references[table] then
		error"orphan table"
	end
	table = self:_dump(table)
	local key, short_key = self:_dump(key, true)
	self:log(table .. (short_key and ("." .. key) or ("[" .. key .. "]")) .. "=" .. self:_dump(value))
end

function mobs_exp.lua_log_file:set_root(key, value)
	return self:set(self.root, key, value)
end

function mobs_exp.lua_log_file:_write()
	self.references = {}
	self.reference_count = 0
	self:log"R={}"
	self:_dump(self.root)
end

function mobs_exp.lua_log_file:_rewrite()
	self.file = io.open(self.file_path, "w+")
	self:_write()
	self.file:close()
end

function mobs_exp.lua_log_file:rewrite()
	if self.file then
		self.file:close()
	end
	self:_rewrite()
	self:open()
end
