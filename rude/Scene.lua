---A scene object.
-- Each scene defines an independent environment with entities, components, and systems.
--@classmod Scene

local c = require('rude._contract')
local Exception = require('rude.Exception')
local MissingComClassException = require('rude.MissingComClassException')
local RudeObject = require('rude.RudeObject')
local util = require('rude.util')
local TypeError = require('rude.TypeError')

local Scene = RudeObject:subclass('Scene')

function Scene:initialize(engine, config)
    c('rt,rt,t')
    RudeObject.initialize(self)
    self.engine = engine

    --entity/component stuff
    self.com = {}
    self.tags = {}
    self._hasComIterCache = {}
    self._tagIterCache = {}
    self._nextEntId = 1
    self.removedEnts = {}

    --event states
    self._isPaused = false
    self._isVisible = true
    self._isSetup = false
    self._isInputEnabled = true
    self._eventHandlers = {}

    --setup config
    self.config = {
        user={}
    }
    if config then
        self:updateConfig(config)
    end

    return self
end

function Scene:updateConfig(config)
    c('rt,rt')
    if type(config.user) == 'table' then
        self.engine:mergeData(config.user, self.config.user)
    else
        self.engine:log(TypeError(config.user, 'config.user', 'table'))
    end
    return self
end

--|-----------------------------------------------------------------------------
--| Callback functions
--|-----------------------------------------------------------------------------
-- All callback functions are intended to be overridden by the user. These all start with the word "on" to help distinguish them from the corresponding event methods, which should NOT be overridden. These callbacks are not intended to be called directly by the user's code; instead, the event methods are used to call these callbacks at the appropriate times.

---Callback used for setting up the scene.
-- Setup occurs AFTER initialization but BEFORE any updates or drawing. The allows the user to, for example, initialize a scene before loading any startup data or assets.
function Scene:onSetup(...)

end

---Callback used for tearing down the scene.
-- This allows the user to release various data from the scene when it is no longer needed. It could also be used as a way to restart the scene by calling setup() again after tearDown().
function Scene:onTearDown(...)

end

---Callback used for updating the scene.
function Scene:onUpdate(dt)

end

---Callback used for drawing operations.
function Scene:onDraw()

end

---Callback for handling key pressed events.
function Scene:onKeyPressed(key, scancode, isrepeat)

end

---Callback for handling key released events.
function Scene:onKeyReleased(key, scancode)

end

---Callback for handling when a mouse moves.
function Scene:onMouseMoved(x, y, dx, dy, istouch)

end

---Callback for handling when a mouse button is pressed.
function Scene:onMousePressed(x, y, button, istouch, presses)

end

---Callback for handling when a mouse button is released.
function Scene:onMouseReleased(x, y, button, istouch, presses)

end

---Callback for handling when a mouse wheel is moved.
function Scene:onWheelMoved(x, y)

end

---A callback that handles arbitrary events for the scene (i.e. from Scene:emit()).
function Scene:onEvent(event, ...)

end

--|-----------------------------------------------------------------------------
--| Event methods
--|-----------------------------------------------------------------------------
-- These methods trigger various events and state changes for the scene. Most of these are intended to be called from the owning engine instance, but some, like pause() and hide(), are used to change the scene's pause and visibility states.

---Sets up the scene manually by calling onSetup().
-- This will only call onSetup() once. In order to run setup() again, the user must first call tearDown().
function Scene:setup(...)
    if not self._isSetup then
        local ok, err = self:onSetup(...)
        self._isSetup = true
        return ok, err
    end
    return true
end

---Tears down the scene by calling onTearDown().
function Scene:tearDown(...)
    if self._isSetup then
        local ok, err = self:onTearDown(...)
        self._isSetup = false
        return ok, err
    end
    return true
end

---Returns true if the scene has been setup already, otherwise false.
function Scene:isSetup()
    return self._isSetup
end

---Pauses the scene, preventing any further updates.
function Scene:pause()
    c('rt')
    self._isPaused = true
    return self
end

---Resumes the scene from a paused state, allowing updates to continue.
function Scene:resume()
    c('rt')
    self._isPaused = false
    return self
end

---Toggle the paused/running state of the scene.
function Scene:togglePause()
    c('rt')
    self._isPaused = not self._isPaused
    return self
end

---Returns true if scene is currently paused, otherwise false.
function Scene:isPaused()
    return self._isPaused
end

---Hides the scene, preventing any graphics from being rendered.
function Scene:hide()
    c('rt')
    self._isVisible = false
    return self
end

---Shows the scene, allowing graphics to be rendered again after hiding.
function Scene:show()
    c('rt')
    self._isVisible = true
    return self
end

---Toggles the visibility (hide/show) state of the scene.
function Scene:toggleVisibility()
    c('rt')
    self._isVisible = not self._isVisible
    return self
end

---Returns true if scene is currently visible, otherwise returns false.
function Scene:isVisible()
    return self._isVisible
end

---Allows input events (e.g. keys, mouse) to be handled by this scene.
function Scene:enableInput()
    self._isInputEnabled = true
    return self
end

---Disables input events (e.g. keys, mouse) from being handled by this scene.
function Scene:disableInput()
    self._isInputEnabled = false
    return self
end

---Toggles the input enable/disable state.
function Scene:toggleInput()
    self._isInputEnabled = not self._isInputEnabled
    return self
end

---Returns true if inputs are enabled, otherwise false.
function Scene:isInputEnabled()
    return self._isInputEnabled
end

---Updates the scene.
function Scene:update(dt)
    c('rt,rn')
    local ok, err = self:setup()
    if not ok and err then
        self.engine:log(err)
    end
    if not self._isPaused then
        local ok, err = self:onUpdate(dt)
        if not ok and err then
            self.engine:log(err)
        end
        --Remove entities flagged with removeEntDelayed()
        for i, id in ipairs(self.removedEnts) do
            self:removeEnt(id)
        end
        util.clearTable(self.removedEnts)
    end
    return true
end

---Draws the scene to the screen.
function Scene:draw()
    c('rt')
    local ok, err = self:setup()
    if not ok and err then
        self.engine:log(err)
    end
    if self._isVisible then
        local ok, err = self:onDraw()
        if not ok and err then
            self.engine:log(err)
        end
    end
    return true
end

---Handles key pressed logic for the scene.
function Scene:keyPressed(key, scancode, isrepeat)
    c('rt,rs,rs,rb')
    if self._isInputEnabled then
        local consumed, err = self:onKeyPressed(key, scancode, isrepeat)
        if err then
            self.engine:log(err)
        end
        return consumed
    end
    return false
end

---Handles key release logic for the scene.
function Scene:keyReleased(key, scancode)
    c('rt,rs,rs')
    if self._isInputEnabled then
        local consumed, err = self:onKeyReleased(key, scancode)
        if err then
            self.engine:log(err)
        end
        return consumed
    end
    return false
end

---Handles mouse moved logic for the scene.
function Scene:mouseMoved(x, y, dx, dy, istouch)
    c('rt,rn,rn,rn,rn,rb')
    if self._isInputEnabled then
        local consumed, err = self:onMouseMoved(x, y, dx, dy, istouch)
        if err then
            self.engine:log(err)
        end
        return consumed
    end
    return false
end

---Handles mouse button pressed logic for the scene.
function Scene:mousePressed(x, y, button, istouch, presses)
    c('rt,rn,rn,rn,rb,rn')
    if self._isInputEnabled then
        local consumed, err = self:onMousePressed(x, y, button, istouch, presses)
        if err then
            self.engine:log(err)
        end
        return consumed
    end
    return false
end

---Handles mouse button released logic for the scene.
function Scene:mouseReleased(x, y, button, istouch, presses)
    c('rt,rn,rn,rn,rb,rn')
    if self._isInputEnabled then
        local consumed, err = self:onMouseReleased(x, y, button, istouch, presses)
        if err then
            self.engine:log(err)
        end
        return consumed
    end
    return false
end

---Handles mouse wheel moved logic for the scene.
function Scene:wheelMoved(x, y)
    c('rt,rn,rn')
    if self._isInputEnabled then
        local consumed, err = self:onWheelMoved(x, y)
        if err then
            self.engine:log(err)
        end
        return consumed
    end
    return false
end

---Emits a scene event.
function Scene:emit(event, ...)
    c('rt,rs')
    local ok, err = self:onEvent(event, ...)
    if not ok and err then
        self.engine:log(err)
    end
    if self._eventHandlers[event] then
        for i, handler in ipairs(self._eventHandlers[event]) do
            ok, err = handler(...)
            if not ok and err then
                self.engine:log(err)
            end
        end
    end
    return true
end

---Registers a function as an event handler for an event ID.
-- NOTE: because registered event handlers can affect the scene's logic at runtime (and potentially creating hard-to-find bugs), using them is generally not recommended. Consider using the onEvent() callback instead.
function Scene:registerEventHandler(event, idx, handler)
    c('rt,rs,rn|f|t,f|t')
    if handler == nil then
        handler = idx
        idx = nil
        if type(handler) == 'number' then
            error('Must specify an event handler.')
        end
    end
    self._eventHandlers[event] = self._eventHandlers[event] or {}
    if idx then
        table.insert(self._eventHandlers[event], idx, handler)
    else
        table.insert(self._eventHandlers[event], handler)
    end
    return idx or #self._eventHandlers[event]
end

---Removes a previously registered event handler.
function Scene:removeEventHandler(event, idx)
    c('rt,rs,n')
    if self._eventHandlers[event] then
        table.remove(self._eventHandlers[event], idx)
    end
    return true
end

--|-----------------------------------------------------------------------------
--| Entity/component handling functions
--|-----------------------------------------------------------------------------
---Returns a new, unused numeric ID for an entity.
-- This number is always one higher than the previous highest known ID in use. Numbers are not backfilled, e.g. if only one entity with ID 1234 exists, the next value will be 1235 (not 1).

---Adds a new entity to the scene. 
-- If id is nil, a new, unused numeric ID is generated.
-- source can be either a data table or a string corresponding to an importable object.
-- context can be a DataContext object. If nil, the engine's current context will be used.
-- The keys in the source data table can be either component classes or string IDs registered to classes in context. The values can be data that will be merged into component instances.
-- If trying to add an entity ID that already has components associated with it, any new components will be added. Existing components will not be overwritten or merged, and a warning will be raised. It is recommended to only use addEnt with brand-new entities.
-- Each added component will trigger the addedCom event. The order in which components are added is undefined.
-- If successful, the new entity id is returned. If a problem occurred, either the id or nil is returned, followed by an error message.
function Scene:addEnt(source, id, context)
    c('rt,t|s,n|s,t')
    context = context or self.engine.currentContext
    if not id then
        id = self._nextEntId
        self._nextEntId = self._nextEntId + 1
    else
        if type(id) == 'number' then
            if id >= self._nextEntId then
                self._nextEntId = id + 1
            end
        end
    end
    if type(source) == 'string' then
        source = self.engine:importData(source, context)
    end
    if source then
        --process each component
        for comId, comSource in pairs(source) do
            local class, err
            if type(comId) == 'string' then
                class, err = context:getComClass(comId)
                if not class then print(err) end
            elseif type(comId) == 'table' then
                class = comId
            else
                class, err = nil, Exception(('While adding entity %s: comId cannot be type %s.'):format(id, type(comId)))
                print(err)
            end
            if class then
                self.com[class] = self.com[class] or {}
                local com, err = self:addCom(id, class, comSource)
                if not com then print(err) end
            end
        end
    else
        --Because entity IDs are only stored in the component tables, adding an ID without a source table doesn't actually do anything. This is probably not what the user intended, so log a warning.
        self.engine:log(Exception(('Entity id %s added without a source table.'):format(id)))
    end
    self:emit('addedEnt', id)
    return id
end

---Removes an entity from the scene.
function Scene:removeEnt(id)
    c('rt,rn|s')
    self:emit('removingEnt', id)
    --remove all components for this entity
    for class, coms in pairs(self.com) do
        self:removeCom(id, class)
    end
    self:emit('removedEnt', id)
    return self
end

---Flags an entity for removal at the end of the frame.
function Scene:removeEntDelayed(id)
    table.insert(self.removedEnts, id)
end

---Builds a new component and adds it to an entity.
-- Returns the new component table, otherwise returns nil and an exception.
function Scene:addCom(entId, class, source, context)
    c('rt,rn|s,rt|s,t|s,t')
    context = context or self.engine.currentContext
    if type(source) == 'string' then
        source = self.engine:importData(source, context)
    end
    if type(class) == 'string' then
        class, err = context:getComClass(class)
        if not class then return nil, err end
    end
    self.com[class] = self.com[class] or {}
    if self.com[class][entId] then
        return nil, Exception(('Component %s already exists for entity %s.'):format(class, entId))
    end
    self:emit('addingCom', entId, class)
    self.com[class][entId] = class()
    if source then
        self.engine:mergeData(source, self.com[class][entId], context)
    end
    self:emit('addedCom', entId, class)
    return self.com[class][entId]
end

---Removes a component from an entity.
function Scene:removeCom(entId, class, context)
    c('rt,rn|s,rt|s,t')
    context = context or self.engine.currentContext
    if type(class) == 'string' then
        class, err = context:getComClass(class)
        if not class then return nil, err end
    end
    if self.com[class] and self.com[class][entId] then
        self:emit('removingCom', entId, class)
        if self.com[class][entId].destroy then
            self.com[class][entId]:destroy()
        end
        self.com[class][entId] = nil
        self:emit('removedCom', entId, class)
    end
    return self
end

---Returns an entity's component with the given class.
function Scene:getCom(entId, class, context)
    c('rt,rn|s,rt|s,t')
    context = context or self.engine.currentContext
    if type(class) == 'string' then
        local err
        class, err = context:getComClass(class)
        if not class then return nil, err end
    end
    local com = self.com[class] and self.com[class][entId]
    if not com then
        return nil, MissingComClassException(entId, class)
    end
    return com
end

local buildHasComIterKeyTemp = {}
local function buildHasComIterKey(self, ...)
    c('rt')
    util.clearTable(buildHasComIterKeyTemp)
    for i=1, select('#', ...), 1 do
        local class = select(i, ...)
        local err
        if type(class) == 'string' then
            class, err = self.engine.currentContext:getComClass(class)
        elseif type(class) == 'table' then
            --
        else
            class = nil
        end
        if class then
            table.insert(buildHasComIterKeyTemp, tostring(class))
        end
    end
    return table.concat(buildHasComIterKeyTemp, ',')
end

local function buildComClassList(self, tbl, ...)
    c('rt,t')
    tbl = tbl or {}
    for i=1, select('#', ...), 1 do
        local class = select(i, ...)
        local err
        if type(class) == 'string' then
            class, err = self.engine.currentContext:getComClass(class)
        elseif type(class) == 'table' then
            --
        else
            class = nil
        end
        if class then
            table.insert(tbl, class)
        end
    end
    return tbl
end

local hasComIterTempTable = {}
---Returns an iterator that yields entity IDs with all the specified components.  
-- Note that these iterators will be cached to the scene for optimization purposes. You
-- can clear a cached iterator using clearHasComIterCache() or
-- clearAllHasComIterCache().
function Scene:hasComIter(...)
    c('rt')
    local iterKey = buildHasComIterKey(self, ...)
    if self._hasComIterCache[iterKey] then
        return self._hasComIterCache[iterKey]
    end
    --Create the closure
    local entId = nil
    local classes = buildComClassList(self, nil, ...)
    local iter = function()
        if not classes[1] then return end
        if not self.com[classes[1]] then return end
        local found
        while not found do
            entId = next(self.com[classes[1]], entId)
            if entId == nil then
                return
            end
            found = true
            for i=2, #classes, 1 do
                if not self.com[classes[i]] 
                or not self.com[classes[i]][entId]
                then
                    found = false
                end
            end
        end
        return entId
    end
    self._hasComIterCache[iterKey] = iter
    return iter
end

---Clears a cached iterator built from hasComIter().
function Scene:clearHasComIterCache(...)
    c('rt')
    local iterKey = buildHasComIterKey(self, ...)
    self._hasComIterCache[iterKey] = nil
    return self
end

---Clears all cached iterators built from hasComIter().
function Scene:clearAllHasComIterCache()
    c('rt')
    for k, v in pairs(self._hasComIterCache) do
        self._hasComIterCache[k] = nil
    end
    return self
end

local getEntWithComTempTable = {}
---Returns an entity ID with the specified components.  
-- For multiple matching entities, the returned ID is arbitary.
function Scene:getEntWithCom(...)
    c('rt')
    util.clearTable(getEntWithComTempTable)
    local classes = buildComClassList(self, getEntWithComTempTable, ...)
    if not classes[1] then return end
    if not self.com[classes[1]] then return end
    local entId, found
    while not found do
        entId = next(self.com[classes[1]], entId)
        if entId == nil then
            return
        end
        found = true
        for i=2, #classes, 1 do
            if not self.com[classes[i]] 
            or not self.com[classes[i]][entId]
            then
                found = false
            end
        end
    end
    return entId
end

---Checks if an entity ID has the specified components.
function Scene:hasCom(id, ...)
    c('rt,rn|s')
    for i=1, select('#',...), 1 do
        local class = select(i, ...)
        local err
        if type(class) == 'string' then
            class, err = self.engine.currentContext:getComClass(class)
            if not class then return nil, err end
        elseif type(class) == 'table' then
            --
        else
            return nil, Exception(('expected string or table but got %s.'):format(type(class)))
        end
        if self.com[class] and self.com[class][id] then
            --
        else
            return false
        end
    end
    return true
end

---Applies a plugin to the scene.
function Scene:usePlugin(plugin, ...)
    c('rt,rt|f|s')
    if type(plugin) == 'string' then
        plugin = require(plugin)
    end
    plugin(self, ...)
end

--|-----------------------------------------------------------------------------
--| Tagging functions
--|-----------------------------------------------------------------------------
---Tags an entity.
function Scene:tagEnt(id, tag)
    c('rt,rn|s,rn|s')
    self.tags[tag] = self.tags[tag] or {}
    self.tags[tag][id] = true
    return self
end

---Removes a tag for an entity.
function Scene:untagEnt(id, tag)
    c('rt,rn|s,rn|s')
    if not self.tags[tag] then return self end
    self.tags[tag][id] = nil
    return self
end

---Checks if an entity ID is tagged with the specified tags.
function Scene:isEntTagged(id, ...)
    c('rt,rn|s')
    for i=1, select('#',...) do
        local tag = select(i,...)
        if not self.tags[tag] then return false end
        if not self.tags[tag][id] then return false end
    end
    return true
end

---Returns an entity ID that is tagged with the specified tags.
-- For multiple matching IDs, the entity returned is arbitary.
function Scene:getEntWithTag(...)
    c('rt')
    if not self.tags[select(1, ...)] then return end
    local entId, found, done
    while not found and not done do
        entId = next(self.tags[select(1, ...)], entId)
        done = not entId
        for i=1, select('#',...) do
            if entId == nil then
                found = false
                break
            end
            found = self:isEntTagged(entId, select(i,...))
            if not found then
                break
            end
        end
    end
    return entId
end

---Returns an iterator that yields entity IDs with the specified tag(s).
function Scene:tagIter(...)
    c('rt')
    --Look for an existing cached iterator.
    local iterKey = util.concat(',', ...)
    if self._tagIterCache[iterKey] then
        return self._tagIterCache[iterKey]
    end
    --Create the closure
    local entId = nil
    local args = {...}
    local iter = function()
        if not args[1] then return end
        if not self.tags[args[1]] then return end
        local found, done
        while not found and not done do
            entId, _ = next(self.tags[args[1]], entId)
            done = not entId
            for _, tag in ipairs(args) do
                if entId == nil then
                    found = false
                    break
                end
                found = self:isEntTagged(entId, tag)
                if not found then
                    break
                end
            end
        end
        return entId
    end
    self._tagIterCache[iterKey] = iter
    return iter
end

---Clears a cached iterator built from tagIter().
function Scene:clearTagIterCache(...)
    c('rt')
    local iterKey = util.concat(',', ...)
    self._tagIterCache[iterKey] = nil
    return self
end

---Clears all cached iterators built from tagIter().
function Scene:clearAllTagIterCache()
    c('rt')
    for k, v in pairs(self._tagIterCache) do
        self._tagIterCache[k] = nil
    end
    return self
end

return Scene