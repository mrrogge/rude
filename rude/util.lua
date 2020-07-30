---Utility functions.

local c = require('rude._contract')

local mathlog, mathexp = math.log, math.exp

local util = {}

util.emptyTable = {}

---Returns the next unused integer index in a table.
function util.nextIdx(tbl)
    c('rt')
    local iNext = 0
    for i, _ in ipairs(tbl) do
        iNext = i
    end
    return iNext + 1
end

---Computes the geometric mean for a list of numbers.
function util.geomean(...)
    local arg1 = select(1,...)
    if not arg1 then return end
    local arg2 = select(2,...)
    if not arg2 then return arg1 end
    local logSum = 0
    for i=1, select('#',...) do
        local arg = select(i,...)
        logSum = logSum + mathlog(arg)
    end
    return mathexp(logSum/select('#',...))
end

---Computes the sum of a list of numbers.
function util.sum(...)
    local acc = 0
    for i=1, select('#',...) do

        local arg = select(i,...)
        acc = acc + arg
    end
    return acc
end

---Computes the average of a list of numbers.
function util.avg(...)
    if select('#',...) == 0 then return 0 end
    return util.sum(...) / select('#',...)
end

---Always returns true.
function util.alwaysTrue()
    --a function that always returns true
    return true
end

--- A function that does nothing and returns nothing.  
-- This can be used as a placeholder for situations where a function should
-- exist, but its behavior is not important, or it is meant to be overridden
-- with a specific behavior.
function util.alwaysNil() end
util.nop = util.alwaysNil

---Performs a deep copy on a table.
function util.deepCopy(orig, target)
    --TODO: This is largely replaced by the Engine:mergeData() method, but it is probably still useful to have a copy function that does not rely on the context of an engine. Should rewrite this to be a pure deep copy (i.e. not relying on data classes).
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = target or {}
        --If copying a class instance, the "__index" property will have a self-
        --referencing cycle. If this is the case, set the copy's "__index" value
        --to the copy itself, rather than the original instance.
        if orig.__index == orig then
            copy.__index = copy
        end
        for orig_key, orig_value in next, orig, nil do
            if rawget(orig, orig_key) == orig_value then
                if orig_key == 'class' then
                    copy.class = orig_value
                elseif orig_key == '__index' and orig_value == orig then
                    copy.__index = orig
                else
                    copy[util.deepCopy(orig_key)] = util.deepCopy(orig_value)
                end
            end
        end
        setmetatable(copy, getmetatable(orig))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

---Checks if a value is "pure data".  
-- Pure data values are: numbers, strings, booleans, tables, or nil.
function util.isPureData(x)
    --[[An auxilliary function that returns true if x is of type number, string,
    boolean, table, or nil, and false if any other type.]]
    local t = type(x)
    return t == 'number' or t == 'string' or t == 'boolean' or t == 'table'
        or t == 'nil'
end

local function _serializeToLua(o, strings)
    c('ra,rt')
    if type(o) == "number" then
        table.insert(strings, ('%s'):format(o))
    elseif type(o) == "string" then
        table.insert(strings, ('%q'):format(o))
    elseif type(o) == 'boolean' then
        if o then
            table.insert(strings, 'true')
        else
            table.insert(strings, 'false')
        end
    elseif type(o) == "table" then
        table.insert(strings, '{\n')
        for k,v in pairs(o) do
            table.insert(strings, '  [')
            _serializeToLua(k, strings)
            table.insert(strings, '] = ')
            _serializeToLua(v, strings)
            table.insert(strings, ',\n')
        end
        table.insert(strings, '}\n')
    else
        error("cannot serialize a " .. type(o))
    end
end

local _serializeToLuaStrings = {}
---Serializes an object to a Lua string format.
function util.serializeToLua(o)
    util.clearTable(_serializeToLuaStrings)
    table.insert(_serializeToLuaStrings, 'return ')
    _serializeToLua(o, _serializeToLuaStrings)
    return table.concat(_serializeToLuaStrings, '')
end

---Clears all data from a table.
function util.clearTable(t)
    c('rt')
    for k,v in pairs(t) do
        t[k] = nil
    end
    return t
end

---Rounds a number to a specified number of decimal places.
-- Credit to: http://lua-users.org/wiki/SimpleRound
function util.round(num, numDecimalPlaces)
    c('rn,n')
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local concatTempTbl = {}
---Concatenates a list of strings.
function util.concat(sep, ...)
    --Concatenates a series of strings without creating unnecessary intermediate
    --strings in memory.
    util.clearTable(concatTempTbl)
    local iMax = select('#', ...)
    for i=1, iMax, 1 do
        local s = select(i, ...)
        if type(s) ~= 'string' then
            s = tostring(s)
        end
        table.insert(concatTempTbl, s)
    end
    return table.concat(concatTempTbl, sep or '')
end

---Determines if numbers two numbers are within a specified tolerance of each other.
function util.isClose(x, y, mTol, mTol)
    mTol = math.abs(mTol or 1e-12)
    eTol = math.abs(eTol or 0)
    local mx, ex = math.frexp(x)
    local my, ey = math.frexp(y)
    local mErr,eErr = math.abs(mx-my), math.abs(ex-ey)
    return mErr <= mTol and eErr <= eTol
end

return util