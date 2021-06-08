---Applies some basic context to an engine. 
-- All engines automatically use this plugin by default.
-- @module plugins.stdPlugin

local util = require('rude.util')
local contract = require('rude._contract')

---Takes a Lua require path string and returns the corresponding data from that Lua file, i\.e\. the result of `require(input)`.
-- @dDec require
-- @tparam string input the require path.
-- @return the result of `require(input)` if successful, otherwise nil and an error message.
local requireDecoder = function(input)
    contract('rs')
    local result, err = pcall(require, input)
    if not result then
        return nil, err
    end
    return result
end

---Evaluates Lua code passed as a string input, i\.e\. through `loadstring(input)`.
-- 
-- Be careful when running arbitrary code from untrusted sources. It is recommended to set a sandbox environment using `setfenv()`.
-- @dDec lua-string
-- @tparam string input Lua code as a string.
-- @return the result of the evaluated Lua code if valid, otherwise nil and an error message.
local luaStringDecoder = function(input)
    contract('rs')
    local f, err = loadstring(input)
    if not f then
        return nil, err
    end
    local result, err = pcall(f)
    if not result then
        return nil, err
    end
    return result
end

---Encodes Lua data into a valid Lua string.
-- This uses `rude.util.serializeToLua()` to build the string. The result can be loaded at a later time to re-create the original data.
-- An optional path specifies an external file that the string will be written to using `love.filesystem.write()`. If love is not available, this function can still be used by not specifying path.
-- @dEnc lua
-- @tparam number|bool|string|table the Lua data to encode.
-- @tparam[opt] string path a path to an external file that will be written.
-- @return if successful and path was specified, returns true. If successful and path was not specified, returns the data as an encoded string. If not successful, returns nil and an error message.
local luaStringEncoder = function(input, path)
    local result, err = pcall(util.serializeToLua, input)
    if not result then
        return nil, err
    end
    local s = result
    if path then
        if love then
            result, err = love.filesystem.write(path, s)
            if not result then
                return nil, err
            end
            return true
        else
            return nil, 'LOVE2D not found.'
        end
    else
        return s
    end
end

---Applies this plugin to an engine.
-- @function __call
-- @tparam rude.Engine engine The targeted engine.
local plugin = function(engine, context)
    engine:registerDataDecoder('require', requireDecoder, context)
    engine:registerDataDecoder('lua-string', luaStringDecoder, context)
    engine:registerDataEncoder('lua', luaStringEncoder, context)
end

return plugin