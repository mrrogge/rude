---Adds pooling to an object.
-- Classes with PoolableMixin applied will have their instances pooled into a shared TablePool instance. The new() function, instead of creating a brand new object, will borrow from the pool if any previously created instances exist, otherwise a new object will be created like normal.
--   
-- Poolable objects will not have their data emptied before being released back into the pool, so its important to remember to re-initialize them when borrowing.
--   
-- When working with pooled instances, make sure to only release instances that were created within the current scope. For example, if a pooled instance is passed into a function, that function should NOT release the instance, because the calling scope may still need to use the instance after the function call is finished.
-- @classmod PoolableMixin
local c = require('rude._contract')
local TablePool = require('rude.TablePool')

local PoolableMixin = {
    static={}
}

function PoolableMixin.static.new(self, ...)
    local o
    if self.pool:getSize() > 0 then
        o = self.pool:borrow()
    else
        o = self:allocate()
    end
    o:initialize(...)
    return o
end

function PoolableMixin:included(cls)
    cls.pool = TablePool()
end

---Sets the maximum number of objects allowed in the shared class pool.
-- @function static:setPoolSize
function PoolableMixin.static:setPoolSize(max)
    self.pool.max = max
end

---Releases the object back into the pool.
function PoolableMixin:release(noClear)
    if noClear == nil then noClear = true end
    if not noClear then
        if self.destroy then
            self:destroy()
        end
    end
    self.pool:release(self, noClear)
end

return PoolableMixin