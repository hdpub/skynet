
local Player    =   {}

function Player:init_from_create(uid)
    self.uid    =   uid
end

function Player:load_from_db(db_tbl)
    self.uid    =   db_tbl.uid
    self.name   =   db_tbl.name
end

function Player:serialize()
    local db_tbl    =   {
        uid         =   self.uid,
        name        =   self.name,
    }

    return db_tbl
end

function Player:dump_sync_info()
    local sync_tbl    =   {
        uid         =   self.uid,
        name        =   self.name,
    }

    return sync_tbl
end


function Player:get_uid()
    return self.uid
end

function Player:get_name()
    return self.name
end

local api       =   {}

function api.new()
    local player    =   {}
    
    return setmetatable(player, {__index = Player})
end

return api

