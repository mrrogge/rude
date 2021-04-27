---The top-level engine object.
--@classmod Engine

local c = require('rude._contract')
local dkjson = require('dkjson')
local bitser = require('rude.lib.bitser')
local assert = require('rude.assert')
local DataContext = require('rude.DataContext')
local EventEmitterMixin = require('rude.EventEmitterMixin')
local graphics = require('rude.graphics')
local log = require('rude.log')
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
    self.assert = assert
    self.DataContext = DataContext
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

    self.dataContext = DataContext()
    self.currentContext = self.dataContext
    self.scripts = {}

    --private members
    self._initCallbacks = {}
    self._attached = false
    self._dt = 0
    --scene stuff
    self._scenes = {}
    self._sceneStack = {}

    self._importCache = {}
    self._currentLoggerId = nil

    return self
end

--|-----------------------------------------------------------------------------
--| Default Callbacks
--|-----------------------------------------------------------------------------

---Callback function that is called once when the game is loaded.
function Engine:load(...)
    c('rt')
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
        self.log(Exception(tostring(id)..' is not a registered scene ID.'))
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
        self.log(Exception(tostring(id)..' is not a registered scene ID.', 'warning')
    else
        self:pushScene(scene)
    end
    return old
end

--------------------------------------------------------------------------------

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

---Sets a new active data context for all context-specific operations.
-- If context is nil, the active context is set to the engine's default context instance.
function Engine:useContext(context)
    c('rt,t')
    self.currentContext = context or self.dataContext
    return self
end

function Engine:withContext(context, f, ...)
    c('rt,t,rf|t')
    local prevContext = self.currentContext
    self:useContext(context)
    f(...)
    self:useContext(prevContext)
    return self
end

function Engine:getCurrentContext()
    c('rt')
    return self.currentContext
end

---Registers a component class to a string id.
-- If context is a DataContext instance, the class will be registered to it. Otherwise if context is nil, the class will be registered to the Engine's default context.
function Engine:registerComClass(id, class, context)
    c('rt,rs,rt,t')
    context = context or self.currentContext
    context:registerComClass(id, class)
    return self
end

---Returns a registered component class.
function Engine:getComClass(id, context)
    c('rt,rs,t')
    context = context or self.currentContext
    return context:getComClass(id)
end

function Engine:registerClass(class, context)
    c('rt,rt,t')
    context = context or self.currentContext
    context:registerClass(class)
    return self
end

function Engine:registerFunction(id, fnc, context)
    c('rt,rf,t')
    context = context or self.currentContext
    context:registerFunction(id, fnc)
    return self
end

function Engine:getFunction(id, context)
    c('rt,rs,t')
    context = context or self.currentContext
    return context:getFunction(id)
end

function Engine:registerAssetLoader(id, loader, context)
    c('rt,rs,rf|t,t')
    context = context or self.currentContext
    return context:registerAssetLoader(id, loader)
end

function Engine:getAsset(loaderId, assetId, forceLoad, context)
    c('rt,rs,ra,b,t')
    context = context or self.currentContext
    return context:getAsset(loaderId, assetId, forceLoad)
end

function Engine:registerLogger(id, fnc, minSeverity, context)
    context = context or self.currentContext
    return context:registerLogger(id, fnc, minSeverity)
end

function Engine:useLogger(id)
    self._currentLoggerId = id
end

---Logs a payload.
-- This method uses whatever Logger object is currently active for the Engine via useLogger(). This also depends on the current DataContext.
function Engine:log(payload, ...)
    local ok, err = self.currentContext:log(self._currentLoggerId, payload, ...)
    if not ok then
        return nil, err
    end
end

--------------------------------------------------------------------------------
-- External Data Functions
--------------------------------------------------------------------------------
function Engine:mergeData(source, target, context)
    c('rt,rt,rt,t')
    context = context or self.currentContext
    for k, v in pairs(source) do
        local skip = false
        -- ignore any metatable lookup values, we only want data directly added to table
        if rawget(source, k) ~= v then
            skip = true
        end
        -- ignore any keys that are not primitive data types
        local kType = type(k)
        if kType == 'string' or kType == 'number' or kType == 'boolean' then
            --
        else
            skip = true
        end
        -- ignore the "class" field on object instances
        if k == 'class' then
            skip = true
        end
        -- ignore any self-references to avoid cycles.
        if v == source then
            skip = true
        end
        -- ignore any values that aren't primitive data types
        local vType = type(v)
        if vType == 'string' or vType == 'number' or vType == 'boolean'
        or vType == 'table'
        then
            --
        else
            skip = true
        end
        -- ignore __collectionClass and __collectionClasses which are used to identify lists of sub-objects in a given object.
        if k == '__collectionClass' or k == '__collectionClasses' then
            skip = true
        end
        -- if the value has a subclasses attribute, then it is likely a class reference and should be ignored.
        if vType == 'table' and v.subclasses then
            skip = true
        end
        -- ignore any keys that are prefixed with an underscore (flagged as private).
        if not skip and string.find(k, '_') == 1 then
            skip = true
        end
        if not skip then
            -- if v is not a table then just copy it into the target
            if vType ~= 'table' then
                target[k] = v
            else
                -- source value is a table, therefore we want to merge data from this table into the target. Create a new table instance if one does not already exist.
                target[k] = target[k] or {}

                -- if the target has a __collectionClasses value, then this can be used to determine which target tables should be collections of object instances rather than pure tables.
                if target.__collectionClasses
                and type(target.__collectionClasses[k]) == 'table'
                and context.classes[target.__collectionClasses[k]]
                then
                    for k2, v2 in pairs(v) do
                        target[k][k2] = target[k][k2]
                            or context.classes[target.__collectionClasses[k]]()
                        mergeData(self, v2, target[k][k2], context)
                    end
                else
                    -- merge tables normally
                    self:mergeData(v, target[k], context)
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
function Engine:importData(source, context)
    -- TODO: should make dkjson an optional dependency.
    c('rt,rs,t')
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
    context = context or self.currentContext
    target = {}
    self:mergeData(data, target, context)
    self._importCache[source] = target
    return target
end

local _jsonEncodeConfig = {indent=true}
---Exports a data source to an external file.
function Engine:exportData(source, mode, format, fpath, context)
    c('rt,rt,s,s,s,t')
    mode = mode or 's'
    format = format or 'lua'
    local data = {}
    context = context or self.currentContext
    self:mergeData(source, data, context)
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
    self:mergeData(config, self.config, self.currentContext)
    return self
end

return Engine