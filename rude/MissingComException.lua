local Exception = require('rude.Exception')

local MissingComException = Exception:subclass('MissingComException')

function MissingComException:initialize(id, class)
    local msg = ('entity %s missing com %s.'):format(id, class)
    return Exception.initialize(self, msg, 3)
end

return MissingComException