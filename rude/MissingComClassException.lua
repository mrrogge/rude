local Exception = require('rude.Exception')

local MissingComClassException = Exception:subclass('MissingComClassException')

function MissingComClassException:initialize(id)
    local msg = ('No component class registered for ID "%s".'):format(id)
    return Exception.initialize(self, msg, 3)
end

return MissingComClassException