function connectAndSend()

    -- connect to WiFi access point
    wifi.setmode(wifi.STATION);
    wifi.setphymode(wifi.PHYMODE_G);

    pcall(dofile, "data_push.lua")
    --register callback
    wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function() print("STATION_CONNECTING") end)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,       function() print("STATION_CONNECT_FAIL") end)
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function()
        print("STATION_GOT_IP") 
        print(wifi.sta.getip())
        ok, val = pcall(sendMeasurement)
        if ok then
    
        else
            print("Couldn't call sendMeasurement()")   
        end
    end)

    --register callback: use previous state
    -- wifi.sta.eventMonReg(wifi.STA_CONNECTING, function(previous_State)
    --    if(previous_State==wifi.STA_GOTIP) then 
    --        print("Station lost connection with access point\n\tAttempting to reconnect...")
    --    else
    --        print("STATION_CONNECTING")
    --    end
    --end)
    station_cfg={}
    station_cfg.ssid  = ssid;
    station_cfg.pwd   = password;
    station_cfg.auto  = true;
    station_cfg.bssid = mac;
    
    wifi.sta.config(station_cfg);
    --wifi.sta.eventMonStart()
    --wifi.sta.connect();
    --unregister callback
    --wifi.sta.eventMonReg(wifi.STA_IDLE)
    return
end
