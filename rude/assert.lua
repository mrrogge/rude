---assert functions.
-- This module is essentially a wrapper for luassert, but it provides a way to disable all assertions globally. This can be useful for production builds where you do not want assertions to add unnecessary overhead.
--  
-- If luassert is not available (e.g. through luarocks), then this module will behave as though it is disabled all the time.
-- @module assert

local c = require('rude._contract')
local luassert, spy, match, luassert_state, say
local luassert = require('luassert')
local spy = require('luassert.spy')
local match = require('luassert.match')
local luassert_state = require('luassert.state')
local say = require('say')

local dummy = {}
setmetatable(dummy, {
    __call=function(t) return end,
    __index=function(t,k)
        return dummy 
    end,
    __newindex=function(t,k,v) return end
})

if pcall(function() require('luassert') end) then
    luassert = require('luassert')
    spy = require('luassert.spy')
    match = require('luassert.match')
    luassert_state = require('luassert.state')
else
    luassert = dummy
    spy = dummy
    match = dummy
    luassert_state = dummy
end

if pcall(function() require('say') end) then
    say = require('say')
else
    say = dummy
end

local module = {}

---Enables asserts globally.
function module.enable()
    module._disabled = false
end

---Disables asserts globally.
function module.disable()
    module._disabled = true
end

---Toggles asserts enable/disable status.
function module.toggle()
    if module._disabled then
        module.enable()
    else
        module.disable()
    end
end

setmetatable(module, {
    __index=function(t,k)
        if rawget(t, '_disabled') then
            return dummy
        end
        return luassert[k]
    end,
    __call=function(t, ...)
        if rawget(t, '_disabled') then
            return
        end
        return luassert(...)
    end
})

--extensions to luassert
local function isType(state, args)
    return type(args[1]) == args[2]
end
say:set('assertion.isType.positive', 'Expected %s to be type: %s')
say:set('assertion.isType.negative', 'Expected %s to not be type: %s')
luassert:register('assertion', 'Type', isType, 'assertion.isType.positive', 'assertion.isType.negative')

local function hasProp(state, args)
    if type(args[1]) ~= 'table' then
        return false
    end
    return args[1][args[2]]
end
say:set('assertion.hasProp.positive', 'Expected %s to have property: %s')
say:set('assertion.hasProp.negative', 'Expected %s to not have property: %s')
luassert:register('assertion', 'prop', hasProp, 'assertion.hasProp.positive', 'assertion.hasProp.negative')

local function hasCom(state, args)
    local scene = args[1]
    local id = args[2]
    local comId = args[3]
    return scene:hasCom(id, comId)
end
say:set('assertion.component.positive', 'Scene %s: expected entity ID %s to have component ID %s.')
say:set('assertion.component.negative', 'Scene %s: expected entity ID %s to not have component ID %s.')
luassert:register('assertion', 'component', hasCom, 'assertion.component.positive', 'assertion.component.negative')

--define assert for checking that an EventEmitter emitted an event.
local function doesEmitEvent(state, args)
    local snapshot = luassert_state.snapshot()
    local eventEmitter = args[1]
    local event = args[2]
    luassert.is.Type(event, 'string')
    local eventArgs = {}
    for i=3, #args-1, 1 do
        table.insert(eventArgs, args[i])
    end
    local fnc = args[#args]
    spy.on(eventEmitter, 'emit')
    fnc()
    local result = pcall(function()
        luassert.spy(eventEmitter.emit).was.called()
        luassert.spy(eventEmitter.emit).was.called_with(match.is_ref(eventEmitter), event, unpack(eventArgs))
    end)
    snapshot:revert()
    return result
end
say:set('assertion.emitEvent.positive', 'Expected event to be emitted.\nEmitter:\n%s\nevent:\n%s')
say:set('assertion.emitEvent.negative', 'Expected event to not be emitted.\nEmitter:\n%s\nevent:\n%s')
luassert:register('assertion', 'emitEvent', doesEmitEvent, 'assertion.emitEvent.positive', 'assertion.emitEvent.negative')

--assert that a class instance is an instance of a specified class
local function isInstanceOf(state, args)
    local instance = args[1]
    local cls = args[2]
    if type(instance) ~= 'table' or type(cls) ~= 'table' then
        return false
    end
    if not instance.isInstanceOf then
        return false
    end
    return instance:isInstanceOf(cls)
end
say:set('assertion.instanceOf.positive', 'Expected object %s to be instance of %s')
say:set('assertion.instanceOf.negative', 'Expected object %s to not be instance of %s')
luassert:register('assertion', 'instanceOf', isInstanceOf, 'assertion.instanceOf.positive', 'assertion.instanceOf.negative')

--assert that a class instance passes validation
local function isValidInstance(state, args)
    local instance = args[1]
    if type(instance) ~= 'table' then return false end
    if not instance.validate then return false end
    return instance:validate()
end
say:set('assertion.validInstance.positive', 'Instance %s is not valid.')
say:set('assertion.validInstance.negative', 'Instance %s is valid.')
luassert:register('assertion', 'validInstance', isValidInstance, 'assertion.validInstance.positive', 'assertion.validInstance.negative')

return module