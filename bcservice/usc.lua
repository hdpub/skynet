local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local command = {}

local uid2addr  =   {}

function command.login(uid, addr)
    if (uid2addr[uid] == nil) then
        return false, "TID_LOGIN_ALREADY"
    end

    uid2addr[uid]   =   addr

    return true, addr
end

function command.logout(uid, out_addr)
    local addr  =   uid2addr[uid]
    if (addr == out_addr) then
        uid2addr[addr]  =   nil
    end
end

function command.get(uid)
    return uid2addr[uid]
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)

	skynet.register "USC"
end)

