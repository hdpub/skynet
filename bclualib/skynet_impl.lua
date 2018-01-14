
local skynet        =   require "skynet"

function skynet.call_lua(addr, ...)
    return skynet.call(addr, "lua", ...)
end

return skynet


