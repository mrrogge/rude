---Represents an exception where a value was found not to be correct, e.g. a number out of range.

local Exception = require('rude.Exception')
local util = require('rude.util')

local ValueError = Exception:subclass('ValueError')

function ValueError:initialize(msg)
    return Exception.initialize(self, msg, 3)
end

return ValueError