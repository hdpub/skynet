
local skynet = require "skynet"

local CMD = {}
local SOCKET = {}
local gate
local agent             =   {}
local agent_mgr         =   {}

local default_worker_num=   1 

local function choose_min_agent()
    local min_addr  =   nil
    local min_num   =   100000000
    for addr, v in pairs(agent_mgr) do
        if (v < min_num) then
            min_addr=   addr
            min_num =   v
        end
    end

    return min_addr
end

function SOCKET.open(fd, addr)
    local agent_addr  =   choose_min_agent()
    assert(agent_addr)
	skynet.error(string.format("New client from<%s> deal<%x>", addr, agent_addr))

    agent[fd]               =   agent_addr 
    agent_mgr[agent_addr]   =   agent_mgr[agent_addr] + 1   
	skynet.call(agent_addr, "lua", "start", { gate = gate, client = fd, watchdog = skynet.self() })
end

local function close_agent(fd)
	local a = agent[fd]
	agent[fd] = nil
	if a then
		skynet.call(gate, "lua", "kick", fd)
		-- disconnect never return
		skynet.send(a, "lua", "disconnect", fd)
	end
end

function SOCKET.close(fd)
	print("socket close",fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	print("socket error",fd, msg)
	close_agent(fd)
end

function SOCKET.warning(fd, size)
	-- size K bytes havn't send out in fd
	print("socket warning", fd, size)
end

function SOCKET.data(fd, msg)
end

function CMD.start(conf)
	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	close_agent(fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)

	gate = skynet.newservice("gate")

    for i = 1, default_worker_num do
        local addr      =   skynet.newservice("agent")
        assert(addr)
        agent_mgr[addr] =   0
    end
end)

