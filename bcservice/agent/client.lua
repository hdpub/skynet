
local Skynet = require "skynet_impl"
local PlayerMgr     =   require "player_mgr"
local Json          =   require "json"
local DB            =   require "db"

local REQUEST = {}

function REQUEST:get(player)
	print("get", self.what)
	local r = Skynet.call_lua(".simpledb", "get", self.what)
	return { result = r }
end

function REQUEST:set(player)
	print("set", self.what, self.value)
	local r = Skynet.call_lua(".simpledb", "set", self.what, self.value)
end

function REQUEST:handshake(player)
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	Skynet.call_lua(WATCHDOG, "close", client_fd)
end

function REQUEST:hello(player)
    local build_ver     =   self.build_ver
    local res_ver       =   self.res_ver
    if (player ~= nil) then
        return {
            result      =   -1,
            err_msg     =   "TID_INVALID_REQUEST",
        }
    end

    --  TODO:
    local skey          =   "000000000000000000000000"

    return { result = 0, skey = skey, }
end

function REQUEST:login(player, create_fd)
    if (player ~= nil) then
        return {
            result      =   -1,
            err_msg     =   "TID_INVALID_REQUEST",
        }
    end

    --  TODO: decrypt passtoken     
    --  TODO: deal with mul create messages in same time
    local userid    =   self.userid
    if (userid == 0) then
        userid          =   Skynet.call_lua("IDSERVER", "GET", "player") 
        if (userid == nil) then
            return {
                result  =   -1,
                err_msg =   "TID_ERROR_IDSERVER",
            }
        end

        local init_tbl  =   {
                uid     =   userid,
                name    =   "GodV",
        }

        local db_data   =   Json.encode(init_tbl)

        local ok        =   DB.insert("player", userid, db_data)
        if (not ok) then
            return {
                result  =   -1,
                err_msg =   "TID_ERROR_DBBUSY",
            }
        end
    end

    --  usc login
    local ret, msg      =   skynet.call_lua("USC", "login"
                                        , userid
                                        , skynet.self())
    if (not ok) then
        return {
            result      =   ret,
            err_msg     =   msg,
        }
    end

    --  load data from db
    --  TODO:
    local db_data       =   DB.query("player", userid)
    if (db_data == nil) then
        return {
            result      =   -1,
            err_msg     =   "TID_DB_NOTFOUND",
        }
    end

    local db_tbl        =   Json.decode(db_data)
    if (db_tbl == nil) then
        --  TODO: Log Error
        return {
            result      =   -1,
            err_msg     =   "TID_DB_ERROR",
        }
    end

    local player        =   Player.new()
    player:init_from_db(db_tbl)

    PlayerMgr.set(userid, player)

    return {
        result  =   0,
        userid  =   player:get_uid(),
        player  =   player:dump_sync_info(),
    }
end

return REQUEST


