---Provides support for JSON encoding/decoding via the `dkjson` library.
-- `dkjson` can be found here: [http://dkolf.de/src/dkjson-lua.fsl/home](http://dkolf.de/src/dkjson-lua.fsl/home).
-- 
-- It can also be installed via `luarocks`: 
--     luarocks install dkjson
-- @module plugins.dkjsonPlugin

local jsonFound, json = pcall(require, 'dkjson')
local contract = require('rude._contract')

local encoderState = {indent=true}

---Decodes JSON input data into corresponding Lua data.
-- @dDec dkjson-string
-- @tparam string input the JSON string to decode.
-- @return the decoded data if successful, otherwise nil and an error message.
local function stringDecoder(input)
    contract('rs')
    local ret1, ret2, ret3 = json.decode(input)
    if ret1 then
        return ret1
    else
        return nil, ('Decode error at pos %d: %s'):format(ret2, ret3)
    end
end

---Reads and decodes JSON from an external file using `love.filesystem.read()`.
-- @dDec dkjson-file-love
-- @tparam string path the path to the external JSON file.
-- @return the decoded data if successful, otherwise nil and an error message.
local function loveFileDecoder(path)
    contract('rs')
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

---Encodes Lua data into a JSON string and optionally writes out to a file.
-- If path is specified, the JSON string is written out to a file using `love.filesystem.write()`. If love is not available, the encoder can still be used without specifying path, in which case the encoded data will be returned as a string.
-- @dEnc dkjson
-- @tparam number|bool|string|table input the data to encode.
-- @tparam[opt] string path the path to the external file that will be written.
-- @return if successful and path was specified, returns true. If successful and path was not specified, returns the encoded string. If not successful, returns nil and an error message.
local function encoder(input, path)
    contract('rn|b|s|t,s')
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

---Applies this plugin to an engine.
-- @function __call
-- @tparam rude.Engine engine The targeted engine.
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