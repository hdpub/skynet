
local mgr           =   {}

local api           =   {}

function api.get(fd)
    return mgr[fd]
end

function api.set(fd, player)
    mgr[fd]    =   player
end

return api
