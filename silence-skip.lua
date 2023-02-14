local mp = require 'mp'
local msg = require 'mp.msg'
local utils = require 'mp.utils'
local opt = require 'mp.options'

function test()
    -- this is a test

    mp.osd_message("test")
end

mp.add_key_binding("ctrl+shift+alt+t", "test", test)
