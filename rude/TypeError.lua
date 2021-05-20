---Represents an exception where a value was found not to be its expected type.

local Exception = require('rude.Exception')
local util = require('rude.util')

local TypeError = Exception:subclass('TypeError')

function TypeError:initialize(subject, desc, ...)
    subjectType = type(subject)
    desc = desc or '<undefined>'
    desc = tostring(desc)
    local validTypes = util.concat('|', ...)
    local msg = ('%s is type %s but must be: %s'):format(desc, subjectType, 
        validTypes)
    return Exception.initialize(self, msg, 3)
end

return TypeError