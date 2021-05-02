---A scene object.
-- Each scene defines an independent environment with entities, components, and systems.
--@classmod Scene

local c = require('rude._contract')
local Exception = require('rude.Exception')
local MissingComClassException = require('rude.MissingComClassException')
local EventEmitterMixin = require('rude.EventEmitterMixin')
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
    self.com = {}
    self.tags = {}
    self._hasComIterCache = {}
    self._tagIterCache = {}
    self._nextEntId = 1

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
        return nil, MissingComException(entId, class)
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
    return table.concat(',', buildHasComIterKeyTemp)
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
        local found, done
        while not found and not done do
            entId = next(self.com[classes[1]], entId)
            done = not entId
            for i=2, #classes, 1 do
                if entId == nil then
                    found = false
                    break
                end
                found = self.com[classes[i]] and self.com[classes[i]][entId]
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
    local entId, found, done
    while not found and not done do
        entId = next(self.com[classes[1]], entId)
        done = not entId
        for i=2, #classes, 1 do
            if entId == nil then
                found = false
                break
            end
            found = self.com[classes[i]] and self.com[classes[i]][entId]
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