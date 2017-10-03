
function postJson()
    print("POST Measurement")
    http.post(apiUrl .. '/measurements',
              'Content-Type: application/json\r\n',
              json,
              function(code, data)
                if (code < 0) then
                    print("HTTP request failed")
                else
                    print(code, data)
                end
                -- goingSleep()
            end)
end

function goingSleep()
    print("Register Sleep Timer")
    sleep_timer = tmr.create()
    sleep_timer:register(5000, tmr.ALARM_SINGLE, function() 
        print("Disable watering")
        gpio.write(waterPin, gpio.LOW)
        print("Going to sleep")
        wifi.sta.disconnect()
        -- 3600000000 one hour
        -- 59999999 one minute
        -- 4294967295 
        node.dsleep(4294967290)
    end)    
    sleep_timer:start()
end

function sendMeasurement()
    gpio.mode(voltagePin,  gpio.OUTPUT)
    gpio.mode(dmux1Pin,    gpio.OUTPUT)
    gpio.mode(dmux2Pin,    gpio.OUTPUT)
    gpio.mode(waterPin,    gpio.OUTPUT)
    
    gpio.write(voltagePin, gpio.HIGH)
    tsl2561.init(2, 1)
    print(bme280.init(6, 5, nil, nil, nil, 0)) -- initialize to sleep mode 
    
    watering = false;
    gpio.write(dmux1Pin, gpio.LOW)
    gpio.write(dmux2Pin, gpio.LOW)    
    tmr.delay(10000)
    soilS1 = adc.read(0)      
    
    gpio.write(dmux1Pin, gpio.HIGH) 
    tmr.delay(10000)
    soilS2 = adc.read(0)    
    
    gpio.write(dmux1Pin, gpio.LOW)
    gpio.write(dmux2Pin, gpio.HIGH) 
    tmr.delay(10000)
    soilS3 = adc.read(0)    
    
    gpio.write(dmux1Pin, gpio.HIGH)
    gpio.write(dmux2Pin, gpio.HIGH) 
    tmr.delay(10000)
    soilS4 = adc.read(0)    

    --print("soils")
    --print(soilS1)
    --print(soilS2)
    --print(soilS3)
    --print(soilS4)
    if soilS1 < 100 then
        print("Enable watering")
        watering = true
        gpio.write(waterPin, gpio.HIGH)
        tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()        
            print("Disable watering")
            gpio.write(waterPin, gpio.LOW)
            print("Switchoff Sensors")
            gpio.write(voltagePin, gpio.LOW)
        end)
    end    
    
    bme280.startreadout(0, function ()
        P, T = bme280.baro()
        H, T = bme280.humi()
        -- convert measure air pressure to sea level pressure
        QNH = bme280.qfe2qnh(P, 222)
        D = bme280.dewpoint(H, T)

        ok, json = pcall(sjson.encode, {
            lux=tsl2561.getlux(),
            bar=(P/1000.0),
            temp=(T/100.0),
            humidity=(H/1000.0),
            drewpoint=(D/100.0),
            soil1=(soilS1/100.0),
            soil2=(soilS2/100.0), 
            soil3=(soilS3/100.0),  
            soil4=(soilS4/100.0)             
        })
        print(json)
        if ok then   
            pcall(postJson)
            if not watering then            
                print("Disable watering")
                gpio.write(waterPin, gpio.LOW)
                print("Switchoff Sensors")
                gpio.write(voltagePin, gpio.LOW)
            --goingSleep()
            end
        end
    end)
end
