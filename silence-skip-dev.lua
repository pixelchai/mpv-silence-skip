local mp = require 'mp'

mp.enable_messages("debug")
mp.register_event("log-message", function(msg)
    print("a")
end)

mp.register_event("file-loaded", function()
    mp.command("af toggle lavfi=[silencedetect=n=-20dB:d=1]")
    print("added silence detect")
end)
