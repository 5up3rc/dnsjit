-- Copyright (c) 2018, OARC, Inc.
-- All rights reserved.
--
-- This file is part of dnsjit.
--
-- dnsjit is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dnsjit is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dnsjit.  If not, see <http://www.gnu.org/licenses/>.

-- dnsjit.filter.lua
-- Filter through custom Lua function
--   local filter = require("dnsjit.filter.lua").new()
--   filter:push("arg1")
--   filter:push(2)
--   filter:func(function(filter, query, args)
--      local arg1, arg2 = unpack(args, 0)
--      ...
--      filter:send(query)
--   end)
--
-- Filter module to run custom Lua code on received queries with the option
-- to send them to the next receiver.
module(...,package.seeall)

local ch = require("dnsjit.core.chelpers")
local query = require("dnsjit.core.query")
require("dnsjit.filter.lua_h")
local ffi = require("ffi")
local C = ffi.C

local t_name = "filter_lua_t"
local filter_lua_t = ffi.typeof(t_name)
local Lua = {}

-- Create a new Lua filter.
function Lua.new()
    local self = {
        ishandler = false,
        _receiver = nil,
        obj = filter_lua_t(),
    }
    C.filter_lua_init(self.obj)
    ffi.gc(self.obj, C.filter_lua_destroy)
    return setmetatable(self, { __index = Lua })
end

-- Return the Log object to control logging of this instance or module.
function Lua:log()
    if self == nil then
        return C.filter_lua_log()
    end
    return self.obj._log
end

-- Set the function to call on each receive, this function runs in it's own
-- Lua state and in so does not shared any global variables.
function Lua:func(func)
    if self.ishandler then
        error("is handler")
    end
    local bc = string.dump(func)
    return ch.z2n(C.filter_lua_func(self.obj, bc, string.len(bc)))
end

-- Push additional arguments to send to the function, this is the way to
-- pass variables into the new Lua state.
function Lua:push(var)
    local t = type(var)
    if t == "string" then
        return ch.z2n(C.filter_lua_push_string(self.obj, var, string.len(var)))
    elseif t == "number" then
        local n = math.floor(var)
        if n == var then
            return ch.z2n(C.filter_lua_push_integer(self.obj, n))
        else
            return ch.z2n(C.filter_lua_push_double(self.obj, var))
        end
    end
    return 1
end

function Lua:receive()
    if self.ishandler then
        error("is handler")
    end
    self.obj._log:debug("receive()")
    return C.filter_lua_receiver(), self.obj
end

-- Set the receiver to pass queries to.
function Lua:receiver(o)
    if self.ishandler then
        error("is handler")
    end
    self.obj._log:debug("receiver()")
    self.obj.recv, self.obj.robj = o:receive()
    self._receiver = o
end

function Lua.handler()
    return setmetatable({
        ishandler = true,
        _func = nil,
        _recv = nil,
        _robj = nil,
    }, {__index = Lua})
end

function Lua:decompile()
    if not self.ishandler then
        error("not handler")
    end
    self._recv = FILTER_LUA_RECV
    self._robj = FILTER_LUA_ROBJ
    self._func = loadstring(FILTER_LUA_BYTECODE)
end

function Lua:run()
    if not self.ishandler then
        error("not handler")
    end
    local q = query.new(ffi.cast("core_query_t*", FILTER_LUA_QUERY))
    if self._func == nil then
        return
    end
    return self._func(self, q, FILTER_LUA_ARGS)
end

-- Used from the Lua function to send queries to the next receiver.
function Lua:send(query)
    if not self.ishandler then
        error("not handler")
    end
    -- TODO: test replace with ffi.gc(query, nil)
    return ch.z2n(C.receiver_call(self._recv, self._robj, C.core_query_copy(query)))
end

-- dnsjit.filter.thread (3)
return Lua
