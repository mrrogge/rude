-- A wrapper for the optional contract module.
-- If the contract module is found (i.e. through luarocks), then this module references it directly. If not, then this module will do nothing when called.

local nop = function() end

local contractFound, contract = pcall(require, 'contract')
if not contractFound then
    contract = {
        on=nop,
        off=nop,
        isOn=nop,
        toggle=nop,
        config=nop,
        check=nop
    }
    setmetatable(contract, {__call=nop})
end

return contract