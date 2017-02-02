pcall(dofile, "config.lua")

uart.setup(0,115200,8,0,1)
start_timer = tmr.create()
start_timer:register(8000, tmr.ALARM_SINGLE, function() 
    uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
    majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info()
    print("NodeMCU "..majorVer.."."..minorVer.."."..devVer)
    print("Run init.lua")
    pcall(dofile, "connect_and_send.lua")
    ok, val = pcall(connectAndSend)
    if ok then
    
    else
        print("Couldn't call connectAndSend()")    
    end
end
)
start_timer:start()
