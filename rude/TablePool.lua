---A container for pooling objects.
-- The point of a TablePool is simply to define a collection of reusable tables. It provides a way to handle memory management manually as opposed to relying on the garbage collector.
--   
-- With realtime applications like games, garbage collection cycles can have a noticable (and annoying) affect on frame rates. If a function runs every frame, and that function allocates new garbage memory (e.g. creates a new one-off table or closure), then that memory will eventually add up and trigger a collection cycle.
--  
-- Instead, you can minimize the work for the GC and simply reuse an already existing table from a TablePool instance. When you are done using the borrowed table, return it to the pool. This way you can reduce overall garbage buildup, which reduces the frequency of garbage collection cycles, thus improving overall performance. Just make sure you remember to release any tables you borrowed back into their pool, otherwise you won't get any reusability benefits.
--@classmod TablePool

local c = require('rude._contract')
local util = require('rude.util')
local assert = require('rude.assert')
local alert = require('rude.alert')
local RudeObject = require('rude.RudeObject')

local TablePool = RudeObject:subclass('TablePool')

function TablePool:initialize(max)
    c('rt,n')
    self.max = max or 0
    self.pool = {}
    self._tablesToRelease = {}
    return self
end

---Returns true if no tables have been added to the pool, otherwise false.
function TablePool:isEmpty()
    return #self.pool == 0
end

--Returns the number of tables currently held in the pool.
function TablePool:getSize()
    return #self.pool
end

---Get a table from the pool.
-- If the pool is empty, simply return a new table.
function TablePool:borrow()
    c('rt')
    local t
    if #self.pool > 0 then
        t = table.remove(self.pool)
    else
        t = {}
    end
    return t
end

---Return a table to the pool.  
-- Once a table is thrown back to the pool, the user should no longer reference or use it in any way.  
-- By default, the contents of the table will automatically be removed. Passing noClear=true will prevent this function from emptying the data in the table before returning it to the pool. 
function TablePool:release(t, noClear)
    c('rt,rt,b')
    if (self.max > 0 and #self.pool >= self.max) then
        alert('Exceeded TablePool size limit; proceeding to release tables automatically')
        for i=1, math.ceil(#self.pool/2), 1 do
            local t = table.remove(self.pool)
        end
    end
    if not noClear then
        util.clearTable(t)
    end
    table.insert(self.pool, t)
    return self
end

---Remove all tables from the pool.
function TablePool:flush()
    c('rt')
    util.clearTable(self.pool)
    return self
end

return TablePool