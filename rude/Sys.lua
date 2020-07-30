---Base class for all built-in systems.
--@classmod Sys

local c = require('rude._contract')

local RudeObject = require('rude.RudeObject')

local Sys = RudeObject:subclass('Sys')

---Initializes the object.
function Sys:initialize(scene)
    c('rt,rt')
    self.scene = scene
    self.engine = scene.engine
    return self
end

---Applies a plugin to the system.
function Sys:usePlugin(plugin, ...)
    c('rt,rt|f|s')
    if type(plugin) == 'string' then
        plugin = require(plugin)
    end
    plugin(self, ...)
end

return Sys