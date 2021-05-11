---Provides support for JSON encoding/decoding via the dkjson library.

local jsonFound, json = pcall(require, 'dkjson')

local encoderState = {indent=true}

local function stringDecoder(input)
    local ret1, ret2, ret3 = json.decode(input)
    if ret1 then
        return ret1
    else
        return nil, ('Decode error at pos %d: %s'):format(ret2, ret3)
    end
end

local function loveFileDecoder(path)
    local s, err = love.filesystem.read(path)
    if not s then
        return nil, err
    end
    local ret1, ret2, ret3 = json.decode(s)
    if ret1 then
        return ret1
    else
        return nil, ('Decode error at pos %d: %s'):format(ret2, ret3)
    end
end

local function encoder(input, path)
    local s, err = pcall(json.encode, input, encoderState)
    if not s then
        return nil, err
    end
    if path then
        if love then
            local ok
            ok, err = love.filesystem.write(path, s)
            if not ok then
                return nil, err
            else
                return true
            end
        else
            return nil, 'LOVE2D not found.'
        end
    else
        return s
    end
end

return function(engine, context)
    if not jsonFound then
        error('This plugin requires the dkjson module to run correctly.')
    end
    engine:registerDataDecoder('dkjson-string', stringDecoder, context)
    engine:registerDataEncoder('dkjson', encoder, context)
    if love then
        engine:registerDataDecoder('dkjson-file-love', loveFileDecoder, context)
    else
        print('WARNING: love API not found. dkjson-file-love data decoder will not be loaded.')
    end
end