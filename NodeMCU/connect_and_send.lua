function connectAndSend()

    -- connect to WiFi access point
    wifi.setmode(wifi.STATION);
    wifi.setphymode(wifi.PHYMODE_G);

    pcall(dofile, "data_push.lua")
    --register callback
    wifi.sta.eventMonReg(wifi.STA_IDLE,       function() print("STATION_IDLE") end)
    wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("STATION_CONNECTING") end)
    wifi.sta.eventMonReg(wifi.STA_WRONGPWD,   function() print("STATION_WRONG_PASSWORD") end)
    wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("STATION_NO_AP_FOUND") end)
    wifi.sta.eventMonReg(wifi.STA_FAIL,       function() print("STATION_CONNECT_FAIL") end)
    wifi.sta.eventMonReg(wifi.STA_GOTIP, function()
        print("STATION_GOT_IP") 
        print(wifi.sta.getip())
        ok, val = pcall(sendMeasurement)
        if ok then
    
        else
            print("Couldn't call sendMeasurement()")   
        end
    end)

    --register callback: use previous state
    wifi.sta.eventMonReg(wifi.STA_CONNECTING, function(previous_State)
        if(previous_State==wifi.STA_GOTIP) then 
            print("Station lost connection with access point\n\tAttempting to reconnect...")
        else
            print("STATION_CONNECTING")
        end
    end)

    wifi.sta.config("nDSder", "hasenkot", 1, "1c:c6:3c:a2:94:b0");
    wifi.sta.eventMonStart()

    --unregister callback
    wifi.sta.eventMonReg(wifi.STA_IDLE)
    return
end
