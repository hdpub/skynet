
local Skynet        =   require "skynet_impl"

local api       =   {}

function api.insert(tname, key, data)
    local key   =   string.format("%s:%s", tname, key)
    return Skynet.call_lua(".simpledb", "set", key, data)
end

function api.update(tname, key, data)
    local key   =   string.format("%s:%s", tname, key)
    return Skynet.call_lua(".simpledb", "set", key, data)
end

--  TODO:
function api.delete(tname, key)
    local key   =   string.format("%s:%s", tname, key)
    return Skynet.call_lua(".simpledb", "unset", key)
end

function api.query(tname, key)
    local key   =   string.format("%s:%s", tname, key)
    return Skynet.call_lua(".simpledb", "get", key) 
end

return api 

