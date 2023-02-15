local mp = require 'mp'

local original_speed = mp.get_property("speed")
local detected_silence = false

function message_handler(msg)
    -- message must be from ffmpeg
    if msg.prefix ~= "ffmpeg" then
        return
    end

    -- message must be from silencedetect filter
    if string.sub(msg.text, 1, 13) ~= "silencedetect" then
        return
    end

    if string.find(msg.text, "silence_start") and detected_silence == false then
        detected_silence = true
        mp.set_property("speed", original_speed * 10)
        print("silence_start")
    elseif string.find(msg.text, "silence_end") and detected_silence then
        detected_silence = false
        mp.set_property("speed", original_speed)
        print("silence_end")
    end
end

function toggle_filters()
    -- apply noise gate ffmpeg filter
    local noise_gate_filter = "dynaudnorm=g=11"
    mp.command("no-osd af toggle lavfi=[" .. noise_gate_filter .. "]")

    -- apply silencedetect ffmpeg filter
    mp.command("no-osd af toggle lavfi=[silencedetect=n=-20dB:d=0.5]")

    if string.find(mp.get_property("af"), "silencedetect") then
        mp.enable_messages("debug")
        mp.register_event("log-message", message_handler)
        print("registered")
        mp.osd_message("silence detect on")
    else
        mp.set_property("speed", original_speed)
        mp.unregister_event(message_handler)
        print("unregistered")
        mp.osd_message("silence detect off")
    end
end

mp.add_key_binding("F2", "toggle_filters", toggle_filters)
