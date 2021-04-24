--- Manage alerts.
-- Alerts are customized notifications  that allow customized behavior at runtime. You can configure alerts to print to a console, raise an error, run a custom function, or do nothing.
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
local RudeObject = require('rude.RudeObject')

local alert = {
    _defs={},
    _mode='print'
}

local AlertDef = RudeObject:subclass('AlertDef')

function AlertDef:initialize(options)
    c('rt,t')
    self.msg = options.msg or ''
    --mode: 'error'|'print'|'log'|'ignore'|'global'
    self.mode = options.mode or 'global'
    return self
end

function AlertDef:raise(options)
    local msg = options.msg or self.msg
    local mode = options.mode or self.mode
    local fmsg
    if options.params then
        local ok, ret = pcall(msg:format, unpack(options.params))
        if ok then
            fmsg = ret
        else
            fmsg = msg
    else
        fmsg = msg
    end
    fmsg = 'ALERT: '..fmsg
    if mode == 'global' then
        mode = alert._mode
    end
    if mode == 'error' then
        error(fmsg)
    elseif mode == 'print' then
        print(fmsg)
    elseif mode == 'log' then
        --TODO
    elseif mode == 'ignore' then
        --
    else
        --
    end
end

local defaultAlertDef = AlertDef({msg='UNDEFINED'})

function alert.register(id, options)
    c('rs|n,t')
    alert._defs[id] = alert._defs[id] or AlertDef()
    alert._defs[id]:initialize(options)
end

---Raises an alert.
-- If id is an alert ID, then the corresponding registered alert is raised. The options table override any of the registered alert settings, e.g. mode.
-- If id is a table, then a custom alert will be raised based on the option values in that table (in this case the second options parameter is ignored).
function alert.raise(id, options)
    c('rs|n|t,t')
    local alertDef
    if type(id) == 'table' then
        alertDef = AlertDef()
    else
        alertDef = alert._defs[id]
        if not alertDef then
            alertDef = defaultAlertDef
        end
    end
    t:raise
end

--- Alias for raise().
-- @function __call
-- @see raise
setmetatable(alert, {
    __call=function(t, id, ...)
        return t.raise(id, ...)
    end
})

return alert