local TablePool = require('rude.TablePool')
local util = require('rude.util')

describe('TablePool instance', function()
    local tablePool
    before_each(function()
        tablePool = TablePool()
    end)

    -- utility function for making a table with junk data
    local function getJunkTable(t)
        t = t or {}
        t.foo = 1
        t.bar = {
            foo=2
        }
        return t
    end

    describe('initialize()', function()
        it('returns the instance', function()
            local tablePool = TablePool()
            assert.is.equal(tablePool, tablePool:initialize())
        end)
        it('sets the max size', function()
            local max = 10
            local tablePool = TablePool(10)
            assert.is.equal(max, tablePool.max)
        end)
    end)

    describe('borrow()', function()
        it('returns a table', function()
            assert.is.Type(tablePool:borrow(), 'table')
        end)
        it('returns the table that was most recently released', function()
            local t1 = tablePool:borrow()
            local t2 = tablePool:borrow()
            tablePool:release(t1)
            tablePool:release(t2)
            assert.is.equal(tablePool:borrow(), t2)
        end)
    end)

    describe('release()', function()
        it('returns the tablePool', function()
            local t1 = tablePool:borrow()
            assert.is.equal(tablePool, tablePool:release(t1))
        end)
        it('clears the table when noClear is false', function()
            local t1 = tablePool:borrow()
            getJunkTable(t1)
            tablePool:release(t1, false)
            assert.is.same(t1, {})
        end)
        it('preserves table data when noClear is true', function()
            local t1 = tablePool:borrow()
            getJunkTable(t1)
            local t2 = util.deepCopy(t1)
            tablePool:release(t1, true)
            assert.is.same(t1, t2)
        end)
        it('does not error when exceeding pool max size', function()
            tablePool.max = 100
            for i=1, tablePool.max, 1 do
                local t = tablePool:borrow()
                tablePool:release(t)
            end
            local t = tablePool:borrow()
            assert.has_no.errors(function()
                tablePool:release(t)
            end)
        end)
        it('does not error when exceeding pool size of 10000, i.e. the hardcoded limit', function()
            for i=1, 10000, 1 do
                local t = tablePool:borrow()
                tablePool:release(t)
            end
            local t = tablePool:borrow()
            assert.has_no.errors(function()
                tablePool:release(t)
            end)
        end)
    end)

    describe('flush()', function()
        it('returns the tablePool', function()
            assert.is.equal(tablePool, tablePool:flush())
        end)
        it('removes all previously released tables from the pool', function()
            local t1 = tablePool:borrow()
            tablePool:release(t1)
            tablePool:flush()
            local t2 = tablePool:borrow()
            assert.is_not.equal(t1, t2)
        end)
    end)
end)