-- This plugin applies some basic additions to an Engine or DataContext instance. All engines automatically use this plugin by default.

local util = require('rude.util')

-- This data decoder will accept a Lua require path string and return the corresponding data from that Lua file.
local requireDecoder = function(input)
    local result, err = pcall(require, input)
    if not result then
        return nil, err
    end
    return result
end

local luaStringDecoder = function(input)
    local result, err = loadstring(input)
    if not result then
        return nil, err
    end
    local f = result
    result, err = pcall(f)
    if not result then
        return nil, err
    end
    return result
end

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

local plugin = function(engine, context)
    engine:registerDataDecoder('require', requireDecoder, context)
    engine:registerDataDecoder('lua-string', luaStringDecoder, context)
    engine:registerDataEncoder('lua', luaStringEncoder, context)
end

return plugin