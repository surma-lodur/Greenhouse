ssid = "<your SSID>"
password = "<your Password>"
mac = "<mac from Access Point>"

apiUrl = "http://192.168.2.112:6060"
voltagePin = 4
waterPin   = 3

-- Your altitude
alt = 222

tmr.register(0, 8000, tmr.ALARM_SINGLE, function() 
    uart.setup(0, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
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
tmr.start(0)
