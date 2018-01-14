local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local db = {}

local command = {}

function command.GET(key)
    local curr  =   db[key]
    if (curr == nil) then
        db[key] =   1
    else
        db[key] =   db[key] + 1
    end

	return db[key]
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

	skynet.register "IDSERVER"
end)

