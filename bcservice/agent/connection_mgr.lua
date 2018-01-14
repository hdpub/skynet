

local api       =   {}

local mgr       =   {}

function api.unset(fd)
    mgr[fd]     =   nil
end

function api.set(fd, gate, watchdog)
    mgr[fd]     =   {
        gate    =   gate,
        watchdog=   watchdog,
    }
end

function api.get(fd)
    local i     =   mgr[fd]
    if (i == nil) then
        return nil
    end

    return i.gate, i.watchdog
end

return api

