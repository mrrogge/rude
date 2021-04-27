--Main module for the Rude package.

--Check for LOVE2D in the global scope. Raise an error if not available.
local missingLoveMsg = 'The Rude engine requires LÖVE framework v11.0 or newer to run correctly. See: https://love2d.org.'
if not love then
    error(missingloveMsg)
end
local major, minor, revision = love.getVersion()
if major < 11 then
    error(missingLoveMsg)
end

local c = require('rude._contract')

local rude = {}

rude.assert=require('rude.assert')
rude.DataContext=require('rude.DataContext')
rude.Engine=require('rude.Engine')
rude.EventEmitterMixin=require('rude.EventEmitterMixin')
rude.graphics=require('rude.graphics')
rude.PoolableMixin=require('rude.PoolableMixin')
rude.RudeObject=require('rude.RudeObject')
rude.Scene=require('rude.Scene')
rude.Sys=require('rude.Sys')
rude.TablePool=require('rude.TablePool')
rude.util=require('rude.util')

setmetatable(rude, {
    __call=function(t, config)
        return t.Engine(config)
    end
})

return rude