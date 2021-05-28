---The top-level engine object.
--@classmod Engine

local c = require('rude._contract')
local bitserPlugin = require('rude.plugins.bitserPlugin')
local DataContext = require('rude.DataContext')
local dkjsonPlugin = require('rude.plugins.dkjsonPlugin')
local Exception = require('rude.Exception')
local logging = require('rude.logging')
local lovePlugin = require('rude.plugins.lovePlugin')
local MissingComClassException = require('rude.MissingComClassException')
local MissingComException = require('rude.MissingComException')
local PoolableMixin = require('rude.PoolableMixin')
local RudeObject = require('rude.RudeObject')
local Scene = require('rude.Scene')
local stdPlugin = require('rude.plugins.stdPlugin')
local Sys = require('rude.Sys')
local TablePool = require('rude.TablePool')
local TypeError = require('rude.TypeError')
local util = require('rude.util')

local Engine = RudeObject:subclass('Engine')

---Initializes the object.
-- @tparam table config a table of configuration values
-- @return the Engine instance
function Engine:initialize(config)
    c('rt,t')
    -- expose the public rude modules to make access easier.
    self.DataContext = DataContext
    self.Engine = Engine
    self.Exception = Exception
    self.logging = logging
    self.MissingComClassException = MissingComClassException
    self.MissingComException = MissingComException
    self.plugins = {
        bitserPlugin=bitserPlugin,
        dkjsonPlugin=dkjsonPlugin,
        lovePlugin=lovePlugin,
        stdPlugin=stdPlugin
    }
    self.PoolableMixin = PoolableMixin
    self.RudeObject = RudeObject
    self.Scene = Scene
    self.Sys = Sys
    self.TablePool = TablePool
    self.util = util

    self.dataContext = DataContext()
    self.currentContext = self.dataContext

    --private members
    self._dt = 0
    --scene stuff
    self._scenes = {}
    self._sceneStack = {}

    self._importCache = {}
    self._currentLoggerId = nil

    --set configuration
    self.config = {
        updateStep = -1,
        maxStep = -1,
        sceneMode = 'single',

        user = {}
    }
    if config then
        self:updateConfig(config)
    end

    self:usePlugin(stdPlugin)

    return self
end

---Updates the configuration values
-- @tparam table config a table of configuration values
-- @return the Engine instance
function Engine:updateConfig(config)
    c('rt,rt')
    if config.updateStep then
        if type(config.updateStep) ~= 'number' then
            self:log(TypeError(config.updateStep, 'config.updateStep', 'number'))
        else
            self.config.updateStep = config.updateStep
        end
    end
    if config.maxStep then
        if type(config.maxStep) ~= 'number' then
            self:log(TypeError(config.maxStep, 'config.maxStep', 'number'))
        else
            self.config.maxStep = config.maxStep
        end
    end
    if config.sceneMode then
        local sceneMode = tostring(config.sceneMode)
        if sceneMode == 'single' or sceneMode == 'multi' then
            self.config.sceneMode = sceneMode
        else
            self:log(ValueError('config.sceneMode must be one of: single|multi.'))
        end
    end
    if config.user then
        if type(config.user) ~= 'table' then
            self:log(TypeError(config.user, 'config.user', 'table'))
        else
            self:mergeData(config.user, self.config.user)
        end
    end
    return self
end

--|-----------------------------------------------------------------------------
--| Default Callbacks
--|-----------------------------------------------------------------------------

---Intended to be called when the program loads.
-- @param ... parameters passed to onLoad()
function Engine:load(...)
    self:onLoad(...)
end

---A callback function for specifying custom logic on load.
function Engine:onLoad(...)

end

local function updateScenes(self, dt)
    c('rt,rn')
    if self.config.sceneMode == 'multi' then
        for i=#self._sceneStack, 1, -1 do
            self._sceneStack[i]:update(dt)
        end
    elseif self.config.sceneMode == 'single' then
        if #self._sceneStack > 0 then
            self._sceneStack[#self._sceneStack]:update(dt)
        end
    else
        self:log(ValueError('unknown value %s for config.sceneMode.'):format(self.config.sceneMode))
    end
end

---Advances the engine by a given timestep.
-- @tparam number dt the timestep in seconds.
function Engine:update(dt)
    c('rt,rn')
    if self.config.maxStep > 0 then
        dt = math.min(dt, self.config.maxStep)
    end
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

---Renders the engine to the screen.
function Engine:draw()
    c('rt')
    if self.config.sceneMode == 'multi' then
        for i=#self._sceneStack, 1, -1 do
            self._sceneStack[i]:draw()
        end
    elseif self.config.sceneMode == 'single' then
        if #self._sceneStack > 0 then
            self._sceneStack[#self._sceneStack]:draw()
        end
    else
        self:log(ValueError('unknown value %s for config.sceneMode.'):format(self.config.sceneMode))
    end
end

---Passes a key press event to the engine.
-- @tparam string key character of the pressed key.
-- @tparam string scancode the scancode representing the pressed key.
-- @tparam bool isRepeat whether this keypress event is a repeat. The delay between key repeats depends on the user's system settings.
function Engine:keyPressed(key, scancode, isRepeat)
    c('rt,rs,rs,rb')
    if self.config.sceneMode == 'single' then
        local scene = self:getTopScene()
        if scene then
            local consumed, err = scene:keyPressed(key, scancode, isRepeat)
            if not consumed and err then
                self:log(err)
            end
        end
    elseif self.config.sceneMode == 'multi' then
        local consumed, err
        for i=#self._sceneStack, 1, -1 do
            consumed, err = self._sceneStack[i]:keyPressed(key, scancode, 
                isRepeat)
            if err then
                self:log(err)
            end
            if consumed then
                break
            end
        end
    else
        self:log(ValueError('unknown value %s for config.sceneMode.'):format(self.config.sceneMode))
    end
end

---Passes a key released event to the engine.
-- @tparam string key character of the pressed key.
-- @tparam string scancode the scancode representing the pressed key.
function Engine:keyReleased(key, scancode) 
    c('rt,rs,rs')
    if self:getSceneStackSize() == 0 then return end
    local scene = self:getTopScene()
    if scene then
        scene:keyReleased(key, scancode)
    end
end

---Passes a mouse move event to the engine.
-- @tparam number x the mouse position on the x axis
-- @tparam number y the mouse position on the y axis
-- @tparam number dx the amount moved on the x axis since the last time this method was called
-- @tparam number dy the amount moved on the y axis since the last time this method was called
-- @tparam bool isTouch true if mouse move originated from a touchscreen device.
function Engine:mouseMoved(x, y, dx, dy, isTouch)
    c('rt,rn,rn,rn,rn,rb')
    if self:getSceneStackSize() == 0 then return end
    local scene = self:getTopScene()
    if scene then
        scene:mouseMoved(x, y, dx, dy, isTouch)
    end
end

---Passes a mouse button pressed event to the engine.
-- @tparam number x the mouse position on the x axis
-- @tparam number y the mouse position on the y axis
-- @tparam number button the button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
-- @tparam bool isTouch true if mouse press originated from a touchscreen device
-- @tparam number presses the number of presses in a short time frame and small area, used to simulate double or triple clicks
function Engine:mousePressed(x, y, button, isTouch, presses)
    c('rt,rn,rn,rn,rb,rn')
    if self:getSceneStackSize() == 0 then return end
    local scene = self:getTopScene()
    if scene then
        scene:mousePressed(x, y, button, isTouch, presses)
    end
end

---Passes a mouse button released event to the engine.
-- @tparam number x the mouse position on the x axis
-- @tparam number y the mouse position on the y axis
-- @tparam number button the button index that was released. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
-- @tparam bool isTouch true if mouse press originated from a touchscreen device
-- @tparam number presses the number of presses in a short time frame and small area, used to simulate double or triple clicks
function Engine:mouseReleased(x, y, button, isTouch, presses)
    c('rt,rn,rn,rn,rb,rn')
    if self:getSceneStackSize() == 0 then return end
    local scene = self:getTopScene()
    if scene then
        scene:mouseReleased(x, y, button, isTouch, presses)
    end
end

---Passes a mouse wheel moved event to the engine.
-- @tparam number x amount of horizontal mouse wheel movement. Positive values indicate movement to the right.
-- @tparam number y amount of vertical mouse wheel movement. Positive values indicate upward movement.
function Engine:wheelMoved(x, y)
    c('rt,rn,rn')
    if self:getSceneStackSize() == 0 then return end
    local scene = self:getTopScene()
    if scene then
        scene:wheelMoved(x, y)
    end
end

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

---Creates a new scene instance, registers it to a given id, and pushes it to the top of the stack.
-- @tparam number|string id the ID for the scene
-- @tparam[opt] class cls the scene class
-- @tparam[opt] table config a table of configuration values passed to the scene
-- @return the new scene instance
function Engine:newScene(id, cls, config)
    c('rt,rn|s,t,t')
    cls = cls or Scene
    local scene = cls(self, config)
    self._scenes[id] = scene
    self:pushScene(id)
    return scene
end

---Registers a scene instance to a given id.
-- @tparam number|string id the ID for the scene
-- @tparam rude.Scene scene the scene instance
-- @return the Engine instance
function Engine:registerScene(id, scene)
    c('rt,rn|s,rt')
    --registers a new scene
    self._scenes[id] = scene
    return self
end

---Removes a registered scene instance.
-- @tparam number|string id the ID for the scene
-- @return the Engine instance
function Engine:unregisterScene(id)
    c('rt,rn|s')
    --removes a scene from the registered scenes
    self._scenes[id] = nil
    return self
end

---Tests if a scene already exists for a given id.
-- @tparam number|string id the ID for the scene
-- @return true if the scene exists, otherwise false
function Engine:sceneExists(id)
    c('rt,rn|s')
    return not not self._scenes[id]
end

---Returns the scene instance that is registered to the specified id.
-- @tparam number|string id the ID for the scene
-- @return the scene instance if it exists, otherwise nil and an exception
function Engine:getScene(id)
    c('rt,rn|s')
    local scene = self._scenes[id]
    if not scene then
        return nil, Exception(('Scene %s does not exist.'):format(id))
    end
    return scene
end

---Checks how many scenes are added to the stack.
-- @treturn number the number of scenes currently on the stack
function Engine:getSceneStackSize()
    c('rt')
    return #self._sceneStack
end

---Checks if a scene exists at a current index on the stack.
-- @tparam number idx the index number
-- @treturn bool true if scene exists, otherwise false
function Engine:sceneExistsAtIndex(idx)
    c('rt,rn')
    return not not self._sceneStack[idx]
end

---Returns the top scene in the stack.
-- @treturn rude.Scene the top scene if one exists, otherwise nil and an exception
function Engine:getTopScene()
    c('rt')
    if #self._sceneStack > 0 then
        return self._sceneStack[#(self._sceneStack)]
    else
        return nil, Exception('No scene exists')
    end
end

---Returns the scene that is the specified offset number from the top.
-- 
-- e.g. passing 0 would return the top scene, passing 1 would return the scene 2nd from the top. Passing nothing defaults to 0.
-- @tparam[opt] number offset the index offset from the top of the stack.
function Engine:getSceneFromTop(offset)
    c('rt,n')
    offset = offset or 0
    local scene = self._sceneStack[#self._sceneStack - offset]
    return scene
end

---Returns the scene at the specified index to the stack.  
-- If no scene exists at that stack index, an error will be raised.
function Engine:getSceneAtIndex(idx)
    c('rt,rn')
    local scene = self._sceneStack[idx]
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
        self.log(Exception(tostring(id)..' is not a registered scene ID.', 'warning'))
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
    c('rt,rt|f|s', self, plugin)
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
    c('rt,rs,rf,t')
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

function Engine:getAssetLoader(id, context)
    c('rt,rs,t')
    context = context or self.currentContext
    return context:getAssetLoader(id)
end

function Engine:getAsset(loaderId, assetId, forceLoad, context)
    c('rt,rs,ra,b,t')
    context = context or self.currentContext
    return context:getAsset(loaderId, assetId, forceLoad)
end

function Engine:registerDataDecoder(id, decoder, context)
    c('rt,rs,rf|t,t', self, id, decoder, context)
    context = context or self.currentContext
    return context:registerDataDecoder(id, decoder)
end

function Engine:getDataDecoder(id, context)
    c('rt,rs,t')
    context = context or self.currentContext
    return context:getDataDecoder(id)
end

function Engine:registerDataEncoder(id, encoder, context)
    context = context or self.currentContext
    return context:registerDataEncoder(id, encoder)
end

function Engine:getDataEncoder(id, context)
    c('rt,rs,t')
    context = context or self.currentContext
    return context:getDataEncoder(id)
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
-- decoderId is an ID to a registered data decoder function. source is the input value that will be passed to the decoder. context defines the DataContext for looking up the data decoder; when context is nil, the current context for the engine is used.
-- This function decodes the source then runs it through mergeData(), resulting in a pure Lua data table. The result should be deterministic for a given decoder function (assuming that function is also deterministic), therefore we can cache the result for next time.
-- The return value is either the decoded data or nil and an error message. Keep in mind the returned data is cached, so if you wish to use this data, e.g. for a component, you will need to run it through another mergeData() call to apply it to a target.
function Engine:importData(decoderId, source, context)
    c('rt,rs,rs,t')
    context = context or self.currentContext
    local result, err = context:getDataDecoder(decoderId)
    if not result then
        return nil, err
    end
    local decoder = result
    if self._importCache[decoder] and self._importCache[decoder][source] then
        return self._importCache[decoder][source]
    end
    result, err = decoder(source)
    if not result then
        return nil, err
    end
    local data = result
    local target = {}
    self:mergeData(data, target, context)
    self._importCache[decoder] = self._importCache[decoder] or {}
    self._importCache[decoder][source] = target
    return target
end

---Encodes a lua table into a format based on the encoderId, either resulting in a string or writing out to an external file.
local exportDataTempTable = {}
function Engine:exportData(encoderId, source, path, context)
    c('rt,rs,rt,s,t')
    context = context or self.currentContext
    for k,v in pairs(exportDataTempTable) do
        exportDataTempTable[k] = nil
    end
    self:mergeData(source, exportDataTempTable, context)
    local result, err = self:getDataEncoder(encoderId)
    if not result then
        return nil, err
    end
    local encoder = result
    return encoder(exportDataTempTable, path)
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
