local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local REQUEST   =   require "client"
local ConnectionMgr     =   require "connection_mgr"
local PlayerMgr         =   require "player_mgr"

local WATCHDOG
local host
local send_request

local CMD = {}

local function request(fd, name, args, response)
    local player    =   PlayerMgr.get(fd)
	local f = assert(REQUEST[name])
	local r = f(args, player, fd)
	if response then
		return response(r)
	end
end

local function send_package(client_fd, pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (fd, source, type, ...)
        print("===============:", fd, source) 
		if type == "REQUEST" then
			local ok, result  = pcall(request, fd, ...)
			if ok then
				if result then
					send_package(fd, result)
				end
			else
				skynet.error(result)
			end
		else
			assert(type == "RESPONSE")
			error "This example doesn't support request client"
		end
	end
}

function CMD.start(conf)
	local fd        = conf.client
	local gate      = conf.gate
    local watchdog  = conf.watchdog

    ConnectionMgr.set(fd, gate, watchdog)

	skynet.fork(function()
		while true do
            if (ConnectionMgr.get(fd) == nil) then
                print("=============closed, leave", fd)
                --  closed 
                break;
            else
			    send_package(fd, send_request("heartbeat", { reserve = 1 }))
			    skynet.sleep(500)
            end
		end
	end)

	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect(fd)
	-- todo: do something before exit
    ConnectionMgr.unset(fd)
	--skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
end)
