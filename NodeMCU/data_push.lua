voltagePin = 4
waterPin   = 3

function postJson()
    print("POST Measurement")
    http.post('http://192.168.2.112:6060/measurements',
              'Content-Type: application/json\r\n',
              json,
              function(code, data)
                if (code < 0) then
                    print("HTTP request failed")
                else
                    print(code, data)
                end
                goingSleep()
            end)
end

function goingSleep()
    print("Register Sleep Timer")
    tmr.register(1, 5000, tmr.ALARM_SINGLE, function() 
        print("Disable watering")
        gpio.write(waterPin, gpio.LOW)
        print("Going to sleep")
        -- 3600000000 one hour
        -- 59999999 one minute
        node.dsleep(3600000000)
    end)    
    tmr.start(1)
end

function sendMeasurement()
    gpio.mode(voltagePin,  gpio.OUTPUT)
    gpio.write(voltagePin, gpio.HIGH)
    gpio.mode(waterPin,    gpio.OUTPUT)
    alt = 222
    tsl2561.init(2, 1)
    print(bme280.init(6, 5, nil, nil, nil, 0)) -- initialize to sleep mode 
    soilS = adc.read(0)  
    print(soilS)
    if soilS < 100 then
        print("Enable watering")
        gpio.write(waterPin, gpio.HIGH)
    end    
    
    bme280.startreadout(0, function ()
        P, T = bme280.baro()
        H, T = bme280.humi()
        -- convert measure air pressure to sea level pressure
        QNH = bme280.qfe2qnh(P, 222)
        D = bme280.dewpoint(H, T)

        ok, json = pcall(cjson.encode, {
            lux=tsl2561.getlux(),
            bar=(P/1000.0),
            temp=(T/100.0),
            humidity=(H/1000.0),
            drewpoint=(D/100.0),
            soil=(soilS/100.0)          
        })
        if ok then   
            postJson()
            --goingSleep()
        else
        print("Disable watering")
            gpio.write(waterPin, gpio.LOW)
        end
        print("Switchoff Sensors")
        gpio.write(voltagePin, gpio.LOW)
    end)
end
