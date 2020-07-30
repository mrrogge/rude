---Base class for all classes in the Rude framework.
--@classmod RudeObject

local c = require('rude._contract')
local class = require('middleclass')

local RudeObject = class('RudeObject')

function RudeObject:initialize()
    self.snapshots = self.snapshots or {}
    return self
end

---Use the validate() method to check that the instance satifies all the
-- requirements of the class, e.g. properties are expected types. This can help
-- with troubleshooting functions that mutate the instance.
function RudeObject:validate()
    return true
end

---Used to clean up the object reference, including all child objects.  
--Call destroy() on an object when you no longer wish to use it. This allows
-- various cleanup actions to occur, for example releasing poolable sub-objects
-- back to their respective pools.  
-- When you call this method, you are accepting that you are done with this 
-- instance, and no further use may occur, otherwise unexpected errors may
-- happen.
function RudeObject:destroy()

end

return RudeObject