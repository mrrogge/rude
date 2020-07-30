---Adds event handling to an class.
-- The EventEmitter mixin is a simple implementation of the Observer pattern. Any instance of EventEmitter can call emit() with an ID that represents an event. Other objects can register event handler functions to a specific event ID, which will be called immediately (in the order they were registered) anytime that event is emitted.
-- @classmod EventEmitterMixin
local c = require('rude._contract')

local util = require('rude.util')
local class = require('middleclass')

local EventEmitterMixin = {
    static={}
}

---Registers a handler function for an event ID.
function EventEmitterMixin:registerEventHandler(eventId, fnc, ehId)
    c('rt,rs,f,n')
    --[[
        eventId: a string representing an event
        fnc: a function that will be called when the event is emitted.
            Arguments passed to the function are at the EventEmitterMixin's
            discretion, and should be documented appropriately.
        ehId: optional. The index number to use for the registered handler.
            If not specified, the first available index will be used.
        return: an integer representing the id of the passed handler
            function. You will need to use this id in the future if
            you wish to remove the event handler for any reason.
        When specifying ehId, if a handler already exists for this index, it
        will be replaced by the new function.
    ]]
    self._handlers = self._handlers or {}
    self._handlers[eventId] = self._handlers[eventId] or {}
    ehId = ehId or util.nextIdx(self._handlers[eventId])
    self._handlers[eventId][ehId] = fnc
    return ehId
end

---Removes an event handler function.
function EventEmitterMixin:removeEventHandler(eventId, ehId)
    c('rt,rs,rn')
    --[[
        eventId: a string representing an event
        ehId: event handler id to be removed
    ]]
    self._handlers = self._handlers or {}
    if self._handlers[eventId] then
        self._handlers[eventId][ehId] = nil
    end
end

---Emits an event ID, calling any registered handler functions.
function EventEmitterMixin:emit(eventId, ...)
    c('rt,rs')
    --[[
        eventId: a string representing an event
        ...: arguments to pass to the event handlers (optional).
    ]]
    self._handlers = self._handlers or {}
    if not self._handlers[eventId] then return end
    for ehId, fnc in pairs(self._handlers[eventId]) do
        self._handlers[eventId][ehId](...)
    end
end

return EventEmitterMixin