--- Create alerts.
-- Alerts are notifications that allow customized behavior at runtime. You can configure alerts to print to a console, raise an error, run a custom function, or do nothing.
--  
-- During development, you can use alerts to log interesting events to the console. Then for production builds, you can change the configuration so that all alerts do nothing.
--  
-- Custom handler functions can be registered to the module with an ID. The function should accept at least one parameter which will be the string message for the alert. The builtin handler IDs are:  
-- - **ignore**: do nothing.  
-- - **print**: prints the alert message to the console.  
-- - **error**: raises an error.  
--  
-- Various alert classes can be registered to the module with an ID. These alert classes can then be set with a handler ID that determines what happens when an alert of that class is raised. The builtin alert classes and their default handlers are as follows:  
-- - **fatal**: calls the "error" handler.  
-- - **warning**: calls the "print" handler.  
-- - **info**: calls the "ignore" handler.  
-- - **default**: calls the "print" handler. (This is the default class used when an alert is raised without a specified class.)  
--  
-- This module can be customized in many different ways. For example, you could change the "info" class to call the "print" handler, allowing for more verbose output when testing. Or you could disable all alerts by setting every class to the "ignore" handler. All of this can be configured at runtime to suit your specific purposes.
-- @module alert

-- TODO: in a future version, it would be nice to combine the features of alerts and asserts together. Both have related intentions, and it would be cleaner to have just one mechanism that checks conditions and allows custom behavior functions.

local c = require('rude._contract')

local function ignore(msg) end

local function print_(msg)
    c('rs')
    print(('ALERT: %s'):format(msg))
end

local function getHandler(handler)
    c('rf|s')
    if type(handler) == 'function' then
        return handler
    end
    if handler == 'print' then
        return print_
    elseif handler == 'error' then
        return error
    elseif handler == 'ignore' then
        return ignore
    else
        error('unknown alert handler: '..handler)
    end
end

local alert = {
    classes={
        fatal='error',
        warning='print',
        info='ignore',
        default='print'
    },
    handlers={
        error=error,
        print=print_,
        ignore=ignore
    }
}

---Registers a handler function.
-- Replaces the current handler if one already exists.
function alert.registerHandler(id, handler)
    c('rn|s,f')
    alert.handlers[id] = handler
end

---Registers an alert class and sets its handler ID.
function alert.registerClass(clsId, handlerId)
    c('rn|s,n|s')
    alert.classes[clsId] = handlerId
end

---Raises an alert.
function alert.raise(msg, clsId, ...)
    c('s,n|s')
    msg = msg or 'something happened'
    clsId = clsId or 'default'
    local handlerId = alert.classes[clsId]
    if not handlerId then
        error(('No handler exists for alert class "%s"'):format(clsId))
    end
    local handler = alert.handlers[handlerId]
    if not handler then
        error(('Alert handler "%s" does not exist.'):format(handlerId))
    end
    handler(msg, ...)
end

--- Alias for raise().
-- @function __call
-- @see raise
setmetatable(alert, {
    __call=function(t, msg, cls, ...)
        return t.raise(msg, cls, ...)
    end
})

return alert