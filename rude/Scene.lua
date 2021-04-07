---A scene object.
-- Each scene defines an independent environment with entities, components, and systems.
--@classmod Scene

local c = require('rude._contract')

local EventEmitterMixin = require('rude.EventEmitterMixin')
local alert = require('rude.alert')
local assert = require('rude.assert')
local RudeObject = require('rude.RudeObject')
local util = require('rude.util')

local Scene = RudeObject:subclass('Scene')
Scene:include(EventEmitterMixin)

function Scene:initialize(engine, config)
    c('rt,rt,t|s')
    RudeObject.initialize(self)
    self.engine = engine
    self.config = {}
    if config then
        self:importConfig(config)
    end

    --entity/component stuff
    self._ents = {}
    self.com = {}
    self.entCount = 0
    self.tags = {}
    self._hasComIterCache = {}
    self._tagIterCache = {}

    self._startState = 'starting'
    self._pauseState = 'paused'
    self._visibleState = 'invisible'
    self._onStartFlag = false
    self._onPauseFlag = false
    self._onResumeFlag = false
    self._onShowFlag = false
    self._onHideFlag = false
    self.removedEnts = {}
    return self
end

--|-----------------------------------------------------------------------------
--| Scene event functions
--|-----------------------------------------------------------------------------

---Called while the scene is starting up.  
-- This can be overridden with game-specific functionality, for example,
-- building the initial entities. Call finishStarting() to finish the starting
-- process, after which this function will no longer be called.
function Scene:whileStarting(dt)
    c('rt,rn')
    self:finishStarting()
end

---Called once while starting up.
function Scene:onStart()
    c('rt')
end

---Completes the startup process.
function Scene:finishStarting()
    c('rt')
    self._startState = 'started'
    return self
end

---Checks if the scene is starting.
function Scene:isStarting()
    c('rt')
    return self._startState == 'starting'
end

---Checks if the scene has already started.
function Scene:isStarted()
    c('rt')
    return self._startState == 'started'
end

---Call this to begin the pause process.  
-- When a scene is paused, its update callback is not called, preventing any
-- entities from being updated. The scene will still be drawn to the screen.
function Scene:pause()
    c('rt')
    if self._pauseState == 'running' then
        self._pauseState = 'pausing'
        self._onPauseFlag = false
    end
    return self
end

---Called when a scene is about to be paused.  
-- This can be overridden with game-specific functionality. Make sure to call
-- finishPausing() to finish the pausing process, after which this function will
-- stop being called.
function Scene:whilePausing(dt)
    c('rt,rn')
    self:finishPausing()
end

---Called once when scene is paused.
function Scene:onPause()
    c('rt')
end

---Completes the pausing process.
function Scene:finishPausing()
    c('rt')
    if self._pauseState == 'pausing' then
        self._pauseState = 'paused'
    end
    return self
end

---Call this to begin resuming the scene.
function Scene:resume()
    c('rt')
    if self._pauseState == 'paused' then
        self._pauseState = 'resuming'
        self._onResumeFlag = false
    end
    return self
end

---Called when a scene is about to resume.
function Scene:whileResuming(dt)
    c('rt,rn')
    self:finishResuming()
end

---Called once when resuming.
function Scene:onResume()
    c('rt')
end

---Call this to finish the resuming process.
function Scene:finishResuming()
    c('rt')
    if self._pauseState == 'resuming' then
        self._pauseState = 'running'
    end
    return self
end

---Toggle the paused/running state of the scene.
function Scene:togglePause()
    c('rt')
    if self:isPaused() then
        self:resume()
    elseif self:isRunning() then
        self:pause()
    end
    return self
end

---Check if the scene is pausing.
function Scene:isPausing()
    c('rt')
    return self._pauseState == 'pausing'
end

---Check if the scene is paused.
function Scene:isPaused()
    c('rt')
    return self._pauseState == 'paused'
end

---Check if the scene is running.
function Scene:isRunning()
    c('rt')
    return self._pauseState == 'running'
end

---Check if the scene is resuming.
function Scene:isResuming()
    c('rt')
    return self._pauseState == 'resuming'
end

---Call this to begin the hiding process.  
-- When a scene is hidden, it is no longer drawn to the screen. The entities
-- will still be updated in the background (unless the scene is also paused).
function Scene:hide()
    c('rt')
    if self._visibleState == 'visible' then
        self._visibleState = 'hiding'
        self._onHideFlag = false
    end
    return self
end

---Called when a scene is about to be hidden.  
-- This can be overridden with game-specific functionality. Make sure to call
-- finishHiding() to finish the hiding process, after which this function will
-- stop being called.
function Scene:whileHiding(dt)
    c('rt,rn')
    self:finishHiding()
end

---Called once while hiding the scene.
function Scene:onHide()
    c('rt')
end

---Call this to finish the hiding process.
function Scene:finishHiding()
    c('rt')
    self._visibleState = 'invisible'
    return self
end

---Call this to show the scene.
function Scene:show()
    c('rt')
    if self._visibleState == 'invisible' then
        self._visibleState = 'showing'
        self._onShowFlag = false
    end
    return self
end

---Called while showing the scene.
function Scene:whileShowing(dt)
    c('rt,rn')
    self:finishShowing()
end

---Called once when the scene is showing.
function Scene:onShow()
    c('rt')
end

---Call this to finish the showing process.
function Scene:finishShowing()
    c('rt')
    if self._visibleState == 'showing' then
        self._visibleState = 'visible'
    end
    return self
end

---Toggles the visibility (hide/show) state of the scene.
function Scene:toggleVisibility()
    c('rt')
    if self:isVisible() then
        self:hide()
    elseif self:isInvisible() then
        self:show()
    end
    return self
end

---Checks if the scene is visble.
function Scene:isVisible()
    c('rt')
    return self._visibleState == 'visible'
end

---Checks if the scene is invisible.
function Scene:isInvisible()
    c('rt')
    return self._visibleState == 'invisible'
end

---Checks if the scene is showing.
function Scene:isShowing()
    c('rt')
    return self._visibleState == 'showing'
end

---Checks if the scene is hiding.
function Scene:isHiding()
    c('rt')
    return self._visibleState == 'hiding'
end

---Called every update frame.
function Scene:onUpdate(dt)

end

---Updates the scene.
function Scene:update(dt)
    c('rt,rn')
    if not self._onStartFlag then
        self:onStart()
        self._onStartFlag = true
    end
    if self._startState == 'starting' then
        self:whileStarting(dt)
    end
    if self._pauseState == 'pausing' then
        if not self._onPauseFlag then
            self:onPause()
            self._onPauseFlag = true
        end
        self:whilePausing(dt)
    end
    if self._pauseState == 'resuming' then
        if not self._onResumeFlag then
            self:onResume()
            self._onResumeFlag = true
        end
        self:whileResuming(dt)
    end
    if self._visibleState == 'hiding' then
        if not self._onHideFlag then
            self:onHide()
            self._onHideFlag = true
        end
        self:whileHiding(dt)
    end
    if self._visibleState == 'showing' then
        if not self._onShowFlag then
            self:onShow()
            self._onShowFlag = true
        end
        self:whileShowing(dt)
    end
    if self._pauseState == 'pausing' or self._pauseState == 'running' then
        self:onUpdate(dt)
    end
    --Remove entities flagged with removeEntDelayed()
    for i, id in ipairs(self.removedEnts) do
        self:removeEnt(id)
    end
    util.clearTable(self.removedEnts)
end

---Called every draw frame.
function Scene:onDraw()

end

---Draws the scene to the screen.
function Scene:draw()
    c('rt')
    local isVisible = self._visibleState == 'visible' 
        or self._visibleState == 'hiding'
        or self._visibleState == 'showing'
    if isVisible then
        self:onDraw()
    end
end

---Called every time a key is pressed.
function Scene:onKeypressed(key, scancode, isrepeat)

end

---Handles key pressed logic for the scene.
function Scene:keypressed(key, scancode, isrepeat)
    c('rt,rs,rs,rb')
    self:onKeypressed(key, scancode, isrepeat)
end

---Called every time a key is released.
function Scene:onKeyreleased(key, scancode)

end

---Handles key release logic for the scene.
function Scene:keyreleased(key, scancode)
    c('rt,rs,rs')
    self:onKeyreleased(key, scancode)
end

function Scene:onMousemoved(x, y, dx, dy, istouch)

end

function Scene:mousemoved(x, y, dx, dy, istouch)
    c('rt,rn,rn,rn,rn,rb')
    self:onMousemoved(x, y, dx, dy, istouch)
end

function Scene:onMousepressed(x, y, button, istouch, presses)

end

function Scene:mousepressed(x, y, button, istouch, presses)
    c('rt,rn,rn,rn,rb,rn')
    self:onMousepressed(x, y, button, istouch, presses)
end

function Scene:onMousereleased(x, y, button, istouch, presses)

end

function Scene:mousereleased(x, y, button, istouch, presses)
    c('rt,rn,rn,rn,rb,rn')
    self:onMousereleased(x, y, button, istouch, presses)
end

function Scene:onWheelmoved(x, y)

end

function Scene:wheelmoved(x, y)
    c('rt,rn,rn')
    self:onWheelmoved(x, y)
end
--------------------------------------------------------------------------------

--|-----------------------------------------------------------------------------
--| Entity/component handling functions
--|-----------------------------------------------------------------------------
local function alertNoEnt(entId)
    alert(('Entity ID %s does not exist'):format(entId), 'warning')
end

---Adds a new entity to the scene. 
-- If id is nil, the next available id number will be used. 
-- source can be either a data table, a require path that resolves to a data table, or an importable file path that resolves to a data table.
-- context can be a DataContext object. If nil, the engine's current context will be used.
-- The keys in the source data table can be either component classes or string IDs registered to classes in context. The values can be data that will be merged into component instances.
--Returns the id of the new entity if successful, otherwise returns nil and an error message.
function Scene:addEnt(source, id, context)
    c('rt,t|s,n|s,t')
    context = context or self.engine.currentContext
    id = id or util.nextIdx(self._ents)
    if self._ents[id] then
        return nil, ('Entity ID %s already exists; either remove the existing entity or use a different ID.'):format(id)
    end
    if type(source) == 'string' then
        source = self.engine:importData(source, context)
    end
    if source then
        --process each component
        for comId, comSource in pairs(source) do
            local class, err
            if type(comId) == 'string' then
                class, err = context:getComClass(class)
                if not class then
                    print(err)
                end
            elseif type(comId) == 'table' then
                class = comId
            else
                class, err = nil, ('While adding entity %s: comId cannot be type %s.'):format(id, type(comId))
            end
            if class then
                self.com[class] = self.com[class] or {}
                if self.com[class][id] then
                    return nil, ('Unexpected component %s already existing for entity %s.'):format(class, id)
                end
                self.com[class][id] = class()
                self.engine:mergeData(comSource, self.com[class][id], context)
            end
        end
    end
    self._ents[id] = true
    self.count = self.count + 1
    self:emit('addedEnt', id)
    return id
end

---Removes an entity from the scene.
function Scene:removeEnt(id)
    c('rt,rn|s')
    if not self._ents[id] then
        print(('Entity ID %s does not exist, could not remove.'):format(id))
        return self
    end
    self:emit('removingEnt', id)
    --remove all components for this entity
    for class, coms in pairs(self.com) do
        self:removeCom(id, class)
    end
    self._ents[id] = nil
    self.count = self.count - 1
    self:emit('removedEnt', id)
    return self
end

---Flags an entity for removal at the end of the frame.
function Scene:removeEntDelayed(id)
    table.insert(self.removedEnts, id)
end

---Checks if an entity exists for a given ID.
function Scene:entExists(id)
    c('rt,rn|s')
    return not not self._ents[id]
end

---Builds a new component and adds it to an entity.
-- Returns the new component table.
function Scene:addCom(entId, class, source, context)
    c('rt,rn|s,rt|s,t|s,t')
    source = source or util.emptyTable
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
        return nil, ('Component %s already exists for entity %s.'):format(class, entId)
    end
    self.com[class][entId] = class()
    self.engine:mergeData(source, self.com[class][entId], context)
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
        if self.com[class][entId].destroy then
            self.com[class][entId]:destroy()
        end
        self.com[class][entId] = nil
    end
    return self
end

---Returns an entity's component with the given comId.  
-- If component or entity does not exist, an error will be raised. To test if a component
-- exists or not, use hasCom().
function Scene:getCom(entId, class, context)
    c('rt,rn|s,rt|s,t')
    context = context or self.engine.currentContext
    if type(class) == 'string' then
        class, err = context:getComClass(class)
        if not class then return nil, err end
    end
    local com = self.com[class] and self.com[class][entId]
    if not com then
        return nil, ('No component of class %s exists for entity %s.'):format(class, entId)
    end
    return com
end

---Returns an iterator that yields entity IDs for the scene.
function Scene:entIter()
    c('rt')
    local id = nil
    return function()
        local val
        id, val = next(self._ents, id)
        return id, val
    end
end

local hasComIterTempTable = {}
---Returns an iterator that yields entity IDs with all the specified components.  
-- Note that these iterators will be cached to the scene for optimization purposes. You
-- can clear a cached iterator using clearHasComIterCache() or
-- clearAllHasComIterCache().
function Scene:hasComIter(...)
    c('rt')
    -- Each cache entry is a string representation of all passed component classes.
    util.clearTable(hasComIterTempTable)
    for i=1, select('#', ...), 1 do
        local class = select(i, ...)
        local err
        if type(class) == 'string' then
            class, err = self.engine.currentContext:getComClass(class)
            if not class then
                error(err)
            end
        elseif type(class) == 'table' then
            --
        else
            error('hasComIter() only accepts component objects or strings.')
        end
        table.insert(hasComIterTempTable, tostring(class))
    end
    --Look for an existing cached iterator.
    local iterKey = table.concat(',', hasComIterTempTable)
    if self._hasComIterCache[iterKey] then
        return self._hasComIterCache[iterKey]
    end
    --Create the closure
    local entId = nil
    local args = {...}
    local iter = function()
        while true do
            local class
            for i=1, #args, 1 do
                class = args[i]
                if type(class) == 'string' then
                    class = self.engine.currentContext:getComClass(class)
                end
                if class then break end
            end
            entId = entId or self.com[]
        end


        local found, done
        while not found and not done do
            entId, _ = next(self.ents, entId)
            done = not entId
            for _, comId in ipairs(args) do
                if entId == nil then
                    found = false
                    break
                end
                found = self:hasCom(entId, comId)
                if not found then
                    break
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
    local iterKey = util.concat(',', ...)
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

---Returns an entity ID with the specified components.  
-- For multiple matching entities, the returned ID is arbitary.
function Scene:getEntWithCom(...)
    c('rt')
    local entId, found, done
    while not found and not done do
        entId = next(self.ents, entId)
        done = not entId
        for i=1, select('#',...) do
            if entId == nil then
                found = false
                break
            end
            found = self:hasCom(entId, select(i,...))
            if not found then
                break
            end
        end
    end
    return entId
end

---Checks if an entity ID has the specified components.
function Scene:hasCom(id, ...)
    c('rt,rn|s')
    if not self:entExists(id) then
        return false
    end
    local ent = self:getEnt(id)
    for i=1, select('#',...) do
        local comId = select(i,...)
        if not ent[comId] then
            return false
        end
    end
    return true
end

---Imports scene data from a source.
function Scene:importData(source)
    c('rt,rt|s')
    local source = self.engine:importData(source)
    for id, ent in pairs(source.ents) do
        self:addEnt(ent, id)
    end
    self.engine:mergeData(source.tags, self.tags)
    return self
end

---Exports scene data to a source.
function Scene:exportData(mode, format, fpath)
    c('rt,s,s,s')
    self.engine:exportData(self, mode, format, fpath)
    return self
end

---Applies a plugin to the scene.
function Scene:usePlugin(plugin, ...)
    c('rt,rt|f|s')
    if type(plugin) == 'string' then
        plugin = require(plugin)
    end
    plugin(self, ...)
end

---Registers a component class to the scene.
function Scene:registerComponentClass(id, componentClass)
    c('rt,rs,rt|f|s')
    if type(componentClass) == 'string' then
        componentClass = require(componentClass)
    end
    self.componentClasses[id] = componentClass
end

---Checks if a component class exists for a given ID.
function Scene:componentClassExists(id)
    return (not not self.componentClasses[id]) or self.engine:componentClassExists(id)
end

---Returns a registered component class.
function Scene:getComponentClass(id)
    c('rt,rs')
    return self.componentClasses[id] or self.engine:getComponentClass(id)
end

---Registers a system class to the scene.
function Scene:registerSystemClass(id, systemClass)
    c('rt,rs,rt|s')
    if type(systemClass) == 'string' then
        systemClass = require(systemClass)
    end
    self.systemClasses[id] = systemClass
end

---Checks if a system class exists for a given ID.
function Scene:systemClassExists(id)
    c('rt,rs')
    return (not not self.systemClasses[id]) or self.engine:systemClassExists(id)
end

---Returns a registered system class.
function Scene:getSystemClass(id)
    c('rt,rs')
    return self.systemClasses[id] or self.engine:getSystemClass(id)
end

---Activates a system for a given ID.
function Scene:useSystem(id, ...)
    c('rt,rs,t|s')
    local cls = self:getSystemClass(id)
    self.systems[id] = cls(self, ...)
end

---Check if the scene is using a given system ID.
function Scene:hasSystem(id)
    c('rt,rs')
    return not not self.systems[id]
end

---Returns the system object for the scene.
function Scene:getSystem(id)
    c('rt,rs')
    assert.is.Truthy(self.systems[id])
    return self.systems[id]
end

---Imports configuration data for the scene.
function Scene:importConfig(config)
    c('rt,rt|s')
    if type(config) == 'string' then
        config = self.engine:importData(config)
    end
    self:mergeData(config, self.config)
    return self
end

---Registers a script function to the scene.
function Scene:registerScript(id, script)
    c('rt,rs,rf')
    self.scripts[id] = script
end

---Checks if a script function exists for a given ID.
function Scene:scriptExists(id)
    c('rt,rs')
    return (not not self.scripts[id]) or self.engine:scriptExists(id)
end

---Returns a registered script function.
function Scene:getScript(id)
    c('rt,rs')
    assert.is.True(self:scriptExists(id))
    return self.scripts[id] or self.engine:getScript(id)
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
    if not self:entExists(id) then return false end
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
    local entId, found, done
    while not found and not done do
        entId = next(self.ents, entId)
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
    --Look for an existing cached iterator.
    local iterKey = util.concat(',', ...)
    if self._tagIterCache[iterKey] then
        return self._tagIterCache[iterKey]
    end
    --Create the closure
    local entId = nil
    local args = {...}
    local iter = function()
        local found, done
        while not found and not done do
            entId, _ = next(self.ents, entId)
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