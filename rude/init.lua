---Main module for the Rude package.
local c = require('rude._contract')

local rude = {}

rude.DataContext=require('rude.DataContext')
rude.Engine=require('rude.Engine')
rude.EventEmitterMixin=require('rude.EventEmitterMixin')
rude.plugins={
    bitserPlugin=require('rude.plugins.bitserPlugin'),
    dkjsonPlugin=require('rude.plugins.dkjsonPlugin'),
    lovePlugin=require('rude.plugins.lovePlugin'),
    stdPlugin=require('rude.plugins.stdPlugin')
}
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
