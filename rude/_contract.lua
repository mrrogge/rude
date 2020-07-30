-- A wrapper for the optional contract module.
-- If the contract module is found (i.e. through luarocks), then this module references it directly. If not, then this module will do nothing when called.

local module

local nop = function() end

if pcall(function() require('contract') end) then
    module = require('contract')
else
    module = {
        on=nop,
        off=nop,
        isOn=nop,
        toggle=nop,
        config=nop
    }
    setmetatable(module, {__call=nop})
end

return module