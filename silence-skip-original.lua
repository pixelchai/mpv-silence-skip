local mp = require 'mp'

local original_speed = mp.get_property("speed")
local detected_silence = false

function test()
    -- this is a test

    mp.osd_message("test")
end

function message_handler(msg)
    -- print(msg)
    print("aaa")
    if string.find(msg, "silence_start") then
        detected_silence = true
        mp.set_property("speed", original_speed * 5)
        print("silence_start")
    elseif string.find(msg, "silence_end") then
        detected_silence = false
        mp.set_property("speed", original_speed)
        print("silence_end")
    end
end

function toggle_filters()
    -- apply compression
    local compression_filter = "compand=0|0:1|1:-90/-900|-70/-70|-30/-9|0/-3:6:0:0:0"
    mp.command("af toggle lavfi=[" .. compression_filter .. "]")

    local message = ""
    if string.find(mp.get_property("af"), "compand") then
        message = message .. " compression on"
    else
        message = message .. " compression off"
    end

    -- apply noise gate
    local noise_gate_filter = "dynaudnorm=g=11"
    mp.command("af toggle lavfi=[" .. noise_gate_filter .. "]")

    if string.find(mp.get_property("af"), "dynaudnorm") then
        message = message .. ", noise gate on"
    else
        message = message .. ", noise gate off"
    end

    -- apply silencedetect
    mp.set_property("af", "silencedetect=n=-20dB:d=1")

    if string.find(mp.get_property("af"), "silencedetect") then
        message = message .. ", silence detect on"
        mp.register_event("log-message", message_handler)
        print("registered")
    else
        message = message .. ", silence detect off"
        mp.set_property("speed", original_speed)
        mp.unregister_event(message_handler)
        print("unregistered")
    end

    mp.osd_message(message)
end

mp.add_key_binding("F2", "toggle_filters", toggle_filters)