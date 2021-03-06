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

-- dnsjit.filter.timing
-- Filter to pass queries to the next receiver based on timing between packets
--   local filter = require("dnsjit.filter.timing").new()
--   ...
--   filter:receiver(...)
--
-- Filter to manipulate processing so it simulates the actual timing when
-- packets arrived or to delay processing.
module(...,package.seeall)

require("dnsjit.filter.timing_h")
local ffi = require("ffi")
local C = ffi.C

local Timing = {}

-- Create a new Timing filter.
function Timing.new()
    local self = {
        _receiver = nil,
        obj = C.filter_timing_new(),
    }
    ffi.gc(self.obj, C.filter_timing_free)
    return setmetatable(self, { __index = Timing })
end

-- Return the Log object to control logging of this instance or module.
function Timing:log()
    if self == nil then
        return C.filter_timing_log()
    end
    return self.obj._log
end

-- Set the timing mode to keep the timing between packets.
function Timing:keep()
    self.obj.mode = "TIMING_MODE_KEEP"
end

-- Set the timing mode to increase the timing between packets by the given
-- number of nanoseconds.
function Timing:increase(ns)
    self.obj.mode = "TIMING_MODE_INCREASE"
    self.obj.inc = ns
end

-- Set the timing mode to reduce the timing between packets by the given
-- number of nanoseconds.
function Timing:reduce(ns)
    self.obj.mode = "TIMING_MODE_REDUCE"
    self.obj.red = ns
end

-- Set the timing mode to multiply the timing between packets by the given
-- factor (float/double).
function Timing:multiply(factor)
    self.obj.mode = "TIMING_MODE_MULTIPLY"
    self.obj.mul = factor
end

function Timing:receive()
    self.obj._log:debug("receive()")
    return C.filter_timing_receiver(), self.obj
end

-- Set the receiver to pass queries to.
function Timing:receiver(o)
    self.obj._log:debug("receiver()")
    self.obj.recv, self.obj.robj = o:receive()
    self._receiver = o
end

return Timing
