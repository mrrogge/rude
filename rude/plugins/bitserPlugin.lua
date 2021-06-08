---Provides support for binary encoding/decoding with the `bitser` external library.
-- `bitser` can be found here: [https://github.com/gvx/bitser](https://github.com/gvx/bitser).
-- @module plugins.bitserPlugin

local contract = require('rude._contract')
local bitserFound, bitser = pcall(require, 'bitser')

---Decodes a bitser string input into corresponding data.
-- @dDec bitser-string
-- @tparam string input the bitser string
-- @return the decoded data if successful, otherwise nil and an error message
local function bitserStringDecoder(input)
    contract('rs')
    local ok, result = pcall(bitser.loads, input)
    if not ok then
        return nil, result
    else
        return result
    end
end

---Decodes bitser data from an external file path using `love.filesystem.read()`.
-- @dDec bitser-file-love
-- @tparam string path the path to the external file.
-- @return the decoded data if successful, otherwise nil and an error message.
local function bitserLoveFileDecoder(path)
    contract('rs')
    local ok, result = pcall(bitser.loadLoveFile, path)
    if not ok then
        return nil, result
    else
        return result
    end
end

---Encodes Lua data input into a bitser string and optionally writes it to an external file.
-- 
-- If path is specified, the bitser string is written out to a file using `love.filesystem.write()`. If love is not available, the encoder can still be used without specifying path, in which case the encoded data will be returned as a string.
-- @dEnc bitser
-- @tparam number|bool|string|table input the data to encode.
-- @tparam[opt] string path the path to the external file that will be written.
-- @return if successful and path was specified, returns true. If successful and path was not specified, returns the encoded string. If not successful, returns nil and an error message.
local function bitserEncoder(input, path)
    contract('rn|b|s|t,s')
    local ok, result
    if path then
        if love then
            ok, result = pcall(bitser.dumpLoveFile, path, input)
        else
            return nil, 'LOVE2D not found.'
        end
    else
        ok, result = pcall(bitser.dumps, input)
    end
    if not ok then
        return nil, result
    else
        --If result is nil then we called dumpLoveFile() which writes the file but doesn't return a value. In this case we return true so we know the call succeeded.
        return result or true
    end
end

---Applies this plugin to an engine.
-- @function __call
-- @tparam rude.Engine engine The targeted engine.
return function(engine, context)
    if not bitserFound then
        error('This plugin requires the bitser module to run correctly.')
    end
    if not jit then
        error('The bitser module requires Lua JIT to run correctly.')
    end
    engine:registerDataDecoder('bitser-string', bitserStringDecoder, context)
    if love then
        engine:registerDataDecoder('bitser-file-love', bitserLoveFileDecoder, 
            context)
    else
        print('WARNING: love API not found. bitser-file-love data decoder will not be registered.')
    end
    engine:registerDataEncoder('bitser', bitserEncoder, context)
end