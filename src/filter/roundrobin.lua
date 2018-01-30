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

-- dnsjit.filter.roundrobin
-- Passthrough to other receivers in a round robin fashion
--   local filter = require("dnsjit.filter.roundrobin").new()
--   filter.receiver(...)
--   filter.receiver(...)
--   filter.receiver(...)
--   input.receiver(filter)
--
-- Filter to pass queries to others in a round robin fashion.
module(...,package.seeall)

local log = require("dnsjit.core.log")
require("dnsjit.filter.roundrobin_h")
local ffi = require("ffi")
local C = ffi.C

local type = "filter_roundrobin_t"
local struct
local mt = {
    __gc = function(self)
        if ffi.istype(type, self) then
            C.filter_roundrobin_destroy(self)
        end
    end,
    __index = {
        new = function()
            local self = struct()
            if not self then
                error("oom")
            end
            if ffi.istype(type, self) then
                C.filter_roundrobin_init(self)
                return self
            end
        end
    }
}
struct = ffi.metatype(type, mt)

local Roundrobin = {}

-- Create a new Roundrobin filter.
function Roundrobin.new()
    local o = struct.new()
    local log = log.new(o.log)
    log:debug("new()")
    return setmetatable({
        _ = o,
        log = log,
        receivers = {},
    }, {__index = Roundrobin})
end

function Roundrobin:receive()
    self.log:debug("receive()")
    return C.filter_roundrobin_receiver(), self._
end

-- Set the receiver to pass queries to, this can be called multiple times to
-- set addtional receivers.
function Roundrobin:receiver(o)
    self.log:debug("receiver()")
    local recv, robj
    recv, robj = o:receive()
    local ret = C.filter_roundrobin_add(self._, recv, robj)
    if ret == 0 then
        table.insert(self.receivers, o)
        return
    end
    return ret
end

return Roundrobin
