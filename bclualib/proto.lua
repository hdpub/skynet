local sprotoparser = require "sprotoparser"

local proto = {}

local function read_file(path)
    local fp        =   io.open(path, "r");
    if (fp == nil) then
        return nil
    end

    local all       =   fp:read("*a")
    io.close(fp)

    return all
end

local cs_proto  =   read_file("proto/cs.proto")
local sc_proto  =   read_file("proto/sc.proto")

assert(cs_proto)
assert(sc_proto)

proto.c2s   = sprotoparser.parse(cs_proto)
proto.s2c   = sprotoparser.parse(sc_proto)

return proto
