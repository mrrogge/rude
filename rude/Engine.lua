---The top-level engine object.
--@classmod Engine

local c = require('rude._contract')
local dkjson = require('dkjson')
local bitser = require('rude.lib.bitser')
local alert = require('rude.alert')
local assert = require('rude.assert')
local EventEmitterMixin = require('rude.EventEmitterMixin')
local graphics = require('rude.graphics')
local PoolableMixin = require('rude.PoolableMixin')
local RudeObject = require('rude.RudeObject')
local Scene = require('rude.Scene')
local Sys = require('rude.Sys')
local TablePool = require('rude.TablePool')
local util = require('rude.util')

local Engine = RudeObject:subclass('Engine')
Engine:include(EventEmitterMixin)

---Initializes the object.
function Engine:initialize(config)
    c('rt,t|s')
    -- expose the public rude modules to make access easier.
    self.alert = alert
    self.assert = assert
    self.Engine = Engine
    self.EventEmitterMixin = EventEmitterMixin
    self.graphics = graphics
    self.PoolableMixin = PoolableMixin
    self.RudeObject = RudeObject
    self.Scene = Scene
    self.Sys = Sys
    self.TablePool = TablePool
    self.util = util

    self.config = {
        updateStep = -1,
        user = {}
    }
    if config then
        self:importConfig(config)
    end

    self.componentClasses = {}
    self.systemClasses = {}
    self.dataClasses = {}
    self.scripts = {}

    --private members
    self._initCallbacks = {}
    self._attached = false
    self._dt = 0
    --scene stuff
    self._scenes = {}
    self._sceneStack = {}

    self._importCache = {}

    return self
end

--|-----------------------------------------------------------------------------
--| Default Callbacks
--|-----------------------------------------------------------------------------

---Callback function that is called once when the game is loaded.
function Engine:load(...)
    c('rt')
    --Use the "nearest" graphics filter, looks a bit better than the default
    love.graphics.setDefaultFilter('nearest', 'nearest', 0)
end

local function updateScenes(self, dt)
    c('rt,rn')
    for i=#self._sceneStack, 1, -1 do
        self._sceneStack[i]:update(dt)
    end
end

---Callback function that is called each update frame.
function Engine:update(dt)
    c('rt,rn')
    if self.config.updateStep > 0 then
        self._dt = self._dt + dt
        while self._dt >= self.config.updateStep do
            updateScenes(self, self.config.updateStep)
            self._dt = self._dt - self.config.updateStep
        end
    else
        updateScenes(self, dt)
    end
end

---Callback function that is called each draw frame.
function Engine:draw()
    c('rt')
    for i=#self._sceneStack, 1, -1 do
        self._sceneStack[i]:draw()
    end
end

---Callback function that is called each time a key is pressed.
function Engine:keypressed(key, scancode, isrepeat)
    c('rt,rs,rs,rb')
    if self:getSceneStackSize() == 0 then return end
    local scene = self:getTopScene()
    if scene then
        scene:keypressed(key, scancode, isrepeat)
    end
end

---Callback function that is called each time a key is released.
function Engine:keyreleased(key, scancode) 
    c('rt,rs,rs')
    if self:getSceneStackSize() == 0 then return end
    local scene = self:getTopScene()
    if scene then
        scene:keyreleased(key, scancode)
    end
end

function Engine:mousemoved(x, y, dx, dy, istouch)
    c('rt,rn,rn,rn,rn,rb')
    if self:getSceneStackSize() == 0 then return end
    local scene = self:getTopScene()
    if scene then
        scene:mousemoved(x, y, dx, dy, istouch)
    end
end

function Engine:mousepressed(x, y, button, istouch, presses)
    c('rt,rn,rn,rn,rb,rn')
    if self:getSceneStackSize() == 0 then return end
    local scene = self:getTopScene()
    if scene then
        scene:mousepressed(x, y, button, istouch, presses)
    end
end

function Engine:mousereleased(x, y, button, istouch, presses)
    c('rt,rn,rn,rn,rb,rn')
    if self:getSceneStackSize() == 0 then return end
    local scene = self:getTopScene()
    if scene then
        scene:mousereleased(x, y, button, istouch, presses)
    end
end

function Engine:wheelmoved(x, y)
    c('rt,rn,rn')
    if self:getSceneStackSize() == 0 then return end
    local scene = self:getTopScene()
    if scene then
        scene:wheelmoved(x, y)
    end
end

--TODO: add the rest of the callback functions
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Scene Functions
--------------------------------------------------------------------------------
local function getScene(self, id)
    c('rt,rt|n|s')
    if type(id) == 'table' then
        return id
    end
    return self._scenes[id]
end

---Creates a new scene and registers it.
-- cls lets you specify the specific scene class to build.
function Engine:newScene(id, cls, ...)
    c('rt,rn|s,t')
    cls = cls or Scene
    local scene = cls(self, ...)
    self._scenes[id] = scene
    return scene
end

---Registers a scene object to the engine with the specified id.
function Engine:registerScene(id, scene)
    c('rt,rn|s,t')
    --registers a new scene
    self._scenes[id] = scene
    return self
end

---Removes a registered scene object from the engine.
function Engine:unregisterScene(id)
    c('rt,rn|s')
    --removes a scene from the registered scenes
    self._scenes[id] = nil
    return self
end

---Returns true if a scene is registered with the specified id; otherwise false.
function Engine:sceneExists(id)
    c('rt,rn|s')
    return not not self._scenes[id]
end

---Returns the scene object that is registered to the specified id.
-- If no scene exists, an error will be raised. Use sceneExists() to test if a scene exists or not.
function Engine:getScene(id)
    c('rt,rn|s')
    assert.is.True(self:sceneExists(id))
    return self._scenes[id]
end

---Returns the number of scenes currently on the stack.
function Engine:getSceneStackSize()
    c('rt')
    return #self._sceneStack
end

---Returns true if an scene currently exists in the stack at the specified index (otherwise return false).
function Engine:sceneExistsAtIndex(idx)
    c('rt,rn')
    return not not self._sceneStack[idx]
end

---Returns the top scene in the stack.
-- If no scenes have been added to the stack, an error will be raised.
function Engine:getTopScene()
    c('rt')
    local scene = self._sceneStack[#(self._sceneStack)]
    assert.is_not.Nil(scene)
    return scene
end

---Returns the scene that is the specified offset number from the top.
-- e.g. passing 0 would return the top scene, passing 1 would return the scene 2nd from the top. Passing nothing defaults to 0.
function Engine:getSceneFromTop(offset)
    c('rt,n')
    offset = offset or 0
    local scene = self._sceneStack[#self._sceneStack - offset]
    assert.is_not.Nil(scene)
    return scene
end

---Returns the scene at the specified index to the stack.  
-- If no scene exists at that stack index, an error will be raised.
function Engine:getSceneAtIndex(idx)
    c('rt,rn')
    local scene = self._sceneStack[idx]
    assert.is_not.Nil(scene)
    return scene
end

---Adds a scene to the top of the stack.  
-- Note: unregistered scenes can be added to the stack by passing the scene object.
function Engine:pushScene(scene)
    c('rt,rn|s|t')
    local id
    if type(scene) == 'string' or type(scene) == 'number' then
        id = scene
        scene = self._scenes[id]
    end
    if not scene then
        alert(tostring(id)..' is not a registered scene ID.', 'warning')
        return
    end
    table.insert(self._sceneStack, scene)
    return self
end

---removes the scene from the top of the stack and returns it.
function Engine:popScene()
    c('rt')
    if #(self._sceneStack) == 0 then
        return nil
    end
    return table.remove(self._sceneStack)
end

---Lookup scene to see if it has an id registered.  
-- If it is, returns the ID, otherwise return nothing.
function Engine:isSceneRegistered(scene)
    c('rt,rt')
    for k,v in pairs(self._scenes) do
        if scene == v then
            return k
        end
    end
end

---Does a pop(), then push() to the scene stack.  
-- Returns the popped scene if there was one.
function Engine:swapScene(scene)
    c('rt,rn|s|t')
    local id
    if type(scene) == 'number' or type(scene) == 'string' then
        id = scene
        scene = self:getScene(id)
    end
    local old = self:popScene()
    if not scene then
        alert(tostring(id)..' is not a registered scene ID.', 'warning')
    else
        self:pushScene(scene)
    end
    return old
end

--------------------------------------------------------------------------------

---Sets up the LOVE environment to use callback functions defined for this engine.
-- Any modifications made to the LOVE callbacks prior to calling attach() will be preserved.
function Engine:attach()
    c('rt')
    self._initCallbacks.load = love.load
    self._initCallbacks.update = love.update
    self._initCallbacks.draw = love.draw
    self._initCallbacks.keypressed = love.keypressed
    self._initCallbacks.keyreleased = love.keyreleased
    self._initCallbacks.mousemoved = love.mousemoved
    self._initCallbacks.mousepressed = love.mousepressed
    self._initCallbacks.mousereleased = love.mousereleased
    love.load = function(...)
        if self._initCallbacks.load then
            self._initCallbacks.load(...)
        end
        self:load(...)
    end
    love.update = function(dt)
        c('rn')
        if self._initCallbacks.update then
            self._initCallbacks.update(dt)
        end
        self:update(dt)
    end
    love.draw = function()
        if self._initCallbacks.draw then
            self._initCallbacks.draw()
        end
        self:draw()
    end
    love.keypressed = function(key, scancode, isrepeat)
        c('rs,rs,rb')
        if self._initCallbacks.keypressed then
            self._initCallbacks.keypressed(key, scancode, isrepeat)
        end
        self:keypressed(key, scancode, isrepeat)
    end
    love.keyreleased = function(key, scancode)
        c('rs,rs')
        if self._initCallbacks.keyreleased then
            self._initCallbacks.keyreleased(key, scancode)
        end
        self:keyreleased(key, scancode)
    end
    love.mousemoved = function(x,y,dx,dy,istouch)
        c('rn,rn,rn,rn,rb')
        if self._initCallbacks.mousemoved then
            self._initCallbacks.mousemoved(x,y,dx,dy,istouch)
        end
        self:mousemoved(x,y,dx,dy,istouch)
    end
    love.mousepressed = function(x,y,button,istouch,presses)
        c('rn,rn,rn,rb,rn')
        if self._initCallbacks.mousepressed then
            self._initCallbacks.mousepressed(x,y,button,istouch,presses)
        end
        self:mousepressed(x,y,button,istouch,presses)
    end
    love.mousereleased = function(x,y,button,istouch,presses)
        c('rn,rn,rn,rb,rn')
        if self._initCallbacks.mousereleased then
            self._initCallbacks.mousereleased(x,y,button,istouch,presses)
        end
        self:mousereleased(x,y,button,istouch,presses)
    end
    self._attached = true
end

---Detaches the engine from the LOVE environment.
-- This resets all LOVE callbacks to their original functions. Does nothing if the engine is not currently attached.
function Engine:detach()
    c('rt')
    if self._attached then
        for k,v in pairs(self._initCallbacks) do
            love[k] = v
            self._initCallbacks[k] = nil
        end
        self._attached = false
    end
end

---loads a general plugin into this engine.  
-- A plugin should be a function or callable table that accepts the engine as
-- the first parameter. Additional parameters can be passed for plugin
-- configuration.  
-- plugin can be either a require path to a plugin module, or the actual plugin
-- object.
function Engine:usePlugin(plugin, ...)
    c('rt,rt|f|s')
    if type(plugin) == 'string' then
        plugin = require(plugin)
    end
    plugin(self, ...)
end

---Registers a component class to the engine.
function Engine:registerComponentClass(id, componentClass)
    c('rt,rs,rt|f|s')
    if type(componentClass) == 'string' then
        componentClass = require(componentClass)
    end
    self.componentClasses[id] = componentClass
end

---Checks if a component class exists for a given ID.
function Engine:componentClassExists(id)
    c('rt,rs')
    return not not self.componentClasses[id]
end

---Returns a registered component class.
function Engine:getComponentClass(id)
    c('rt,rs')
    assert.is.truthy(self.componentClasses[id])
    return self.componentClasses[id]
end

---Registers a system class to the engine.
function Engine:registerSystemClass(id, systemClass)
    c('rt,rs,rt|s')
    if type(systemClass) == 'string' then
        systemClass = require(systemClass)
    end
    self.systemClasses[id] = systemClass
end

---Checks if a system class exists for a given ID.
function Engine:systemClassExists(id)
    c('rt,rs')
    return not not self.systemClasses[id]
end

---Returns a registered system class.
function Engine:getSystemClass(id)
    c('rt,rs')
    assert.is.truthy(self.systemClasses[id])
    return self.systemClasses[id]
end

---Registers a data class to the engine.
function Engine:registerDataClass(id, dataClass)
    c('rt,rs,rt|s')
    if type(dataClass) == 'string' then
        dataClass = require(dataClass)
    end
    self.dataClasses[id] = dataClass
end

---Checks if a data class exists for a given ID.
function Engine:dataClassExists(id)
    c('rt,rs')
    return not not self.dataClasses[id]
end

---Returns a registered data class.
function Engine:getDataClass(id)
    c('rt,rs')
    assert.is.truthy(self.dataClasses[id])
    return self.dataClasses[id]
end

---Registers a script function to the engine.
function Engine:registerScript(id, script)
    c('rt,rs,rf')
    self.scripts[id] = script
end

---Checks if a script function exists for a given ID.
function Engine:scriptExists(id)
    c('rt,rs')
    return not not self.scripts[id]
end

---Returns a registered script function.
function Engine:getScript(id)
    c('rt,rs')
    assert.is.truthy(self.scripts[id])
    return self.scripts[id]
end

--------------------------------------------------------------------------------
-- External Data Functions
--------------------------------------------------------------------------------
---Merges data from a source table into a target table.
function Engine:mergeData(source, target, convertToObjects)
    --TODO: this needs a lot of cleanup
    c('rt,rt,rt,b')
    for k, v in pairs(source) do
        local skip = false
        if rawget(source, k) ~= v then
            --ignore any metatable lookup values, we only want data directly
            --added to table
            skip = true
        end
        local keyIsData = type(k) == 'string' or type(k) == 'boolean' 
            or type(k) == 'number'
        if not skip and not keyIsData then
            --key is not data
            skip = true
        end
        if not skip and k == 'class' then
            --middleclass objects will have a "class" field, ignore it
            skip = true
        end
        if not skip and v == source then
            --ignore any self-references. NOTE: this won't detect cycles between
            --2 or more tables.
            skip = true
        end
        local valIsData = type(v) == 'string' or type(v) == 'boolean'
            or type(v) == 'number' or type(v) == 'table'
        if not skip and not valIsData then
            --ignore any non-data values
            skip = true
        end
        if not skip and k == '__class' then
            --data structures may have a "__class" metadata field defining its
            --intended class name, ignore this
            skip = true
        end
        if not skip and k == '__collectionClass' then
            --data structures may have a "__collectionClass" metadata field 
            --defining the class names of its sub-objects, ignore this
            skip = true
        end
        if not skip and k == '__collectionClasses' then
            --similarly, ignore __collectionClasses
            skip = true
        end
        if not skip and type(v) == 'table' and v.subclasses then
            --classes will have a subclasses field, we want to ignore these
            skip = true
        end
        if not skip and string.find(k, '_') == 1 then
            --skip any keys that start with a "_", treat these as private
            skip = true
        end
        if not skip then
            if type(v) == 'string' or type(v) == 'boolean' or type(v) == 'number' then
                target[k] = v
            else
                --If the source table has a __class value, then this means the
                --target should be made an instance of that class, rather than
                --just a pure table.
                local dataClassExists = v.__class 
                    and type(v.__class) == 'string'
                    and self:dataClassExists(v.__class)
                if dataClassExists and convertToObjects then
                    target[k] = target[k] or self:getDataClass(v.__class)()
                end
                target[k] = target[k] or {}

                --If the target has a __collectionClasses value, then this can
                --be used to determine which target tables should be collections
                --of object instances rather than pure tables.
                local targetColClassExists = target.__collectionClasses
                    and type(target.__collectionClasses[k]) == 'string'
                    and self:dataClassExists(target.__collectionClasses[k])
                if targetColClassExists and convertToObjects then
                    for k2, v2 in pairs(v) do
                        target[k][k2] = target[k][k2]
                            or self:getDataClass(target.__collectionClasses[k])()
                        self:mergeData(v2, target[k][k2], convertToObjects)
                    end
                end

                --If source has a __collectionClass value, this tells the
                --function that every entry in this table should be an instance
                --of that data class.
                local sourceColClassExists = v.__collectionClass
                    and type(v.__collectionClass) == 'string'
                    and self:dataClassExists(v._collectionClass)
                if not targetColClassExists and sourceColClassExists and convertToObjects then
                    for k2, v2 in pairs(v) do
                        target[k][k2] = target[k][k2] or self:getDataClass(v.__collectionClass)()
                        self:mergeData(v2, target[k][k2], convertToObjects)
                    end
                end

                --If neither of the above merge conditions apply, just merge normally.
                if not convertToObjects or (not targetColClassExists and not sourceColClassExists) then
                    self:mergeData(v, target[k], convertToObjects)
                end
            end
        end
    end
end

---Imports a data source, e.g. from an external file.  
-- Various types are supported: JSON, bitser binary data, external LUA files.  
-- Similar to require(), the results are cached for better performance when
-- importing the same source multiple times. If you plan on changing the import
-- source over time, you will need to use clearImportCache().  
-- Sources can be strings, file paths, or require-style paths (only if the file
-- is a LUA file).  
-- Note that any non-data values (e.g. functions, userdata) will be stripped out
-- of the cached result. The only exception is "data objects", which are
-- instances of special classes registered to the engine. When a source table 
-- or subtable has a "__class" entry, the resulting import will create an object
-- of that class instead of the table. Some built-in examples are: vectors, 
-- colors, timers.
function Engine:importData(source)
    -- TODO: should make dkjson an optional dependency.
    c('rt,rs')
    if self._importCache[source] then
        return self._importCache[source]
    end
    local ok, s, data, target, err, _
    --try to load source as a lua file path
    ok, data = pcall(require, source)
    if not ok then
        --try to load source as a general file path
        s = love.filesystem.read(source)
        if not s then
            --try to parse source as a JSON string
            data, _, err = dkjson.decode(source)
            if err then
                --try to parse source as a binary string
                ok, data = pcall(bitser.loads, source)
                if not ok then
                    error('import error: unknown source format.')
                end
            end
        else
            --try to parse the string as JSON
            data, _, err = dkjson.decode(s)
            if err then
                --try to parse string as binary data
                ok, data = pcall(bitser.loads, s)
                if not ok then
                    error('import error: unknown source format.')
                end
            end
        end
    end
    if type(data) ~= 'table' then
        error(('import error: source cannot be type %s'):format(type(data)))
    end
    local dataClassExists = data.__class and type(data.__class) 
        and self:dataClassExists(data.__class)
    if dataClassExists then
        target = self:getDataClass(data.__class)()
    else
        target = {}
    end
    self:mergeData(data, target, true)
    self._importCache[source] = target
    return target
end

local _jsonEncodeConfig = {indent=true}
---Exports a data source to an external file.
function Engine:exportData(source, mode, format, fpath)
    c('rt,rt,s,s,s')
    mode = mode or 's'
    format = format or 'lua'
    local data = {}
    self:mergeData(source, data, false)
    local s
    if format == 'json' then
        s = dkjson.encode(data, _jsonEncodeConfig)
    elseif format == 'bin' then
        s = bitser.dumps(data)
    elseif format == 'lua' then
        s = util.serializeToLua(data)
    else
        error(('bad argument: format cannot be %s'):format(format))
    end
    if mode == 'f' then
        if not fpath then
            error('fpath must be specified.')
        end
        love.filesystem.write(fpath, s)
    elseif mode == 's' then
        return s
    else
        error(('bad argument: mode cannot be %s'):format(mode))
    end
end

---Import configuration data for the engine.
function Engine:importConfig(config)
    c('rt,rt|s')
    if type(config) == 'string' then
        config = self:importData(config)
    end
    self:mergeData(config, self.config)
    return self
end

---Applies snapshot id to an object.
-- Snapshots are pre-defined sets of values that can be recalled for an object.
function Engine:applySnapshot(object, id)
    local snapshot = object.snapshots[id]
    self:mergeData(snapshot, object)
    return self
end


return Engine