local contract = require('rude._contract')
local bitserFound, bitser = pcall(require, 'bitser')

---Decodes a bitser string input and returns the result if successful, otherwise returns nil and an error message.
local function bitserStringDecoder(input)
    contract('rs')
    local ok, result = pcall(bitser.loads, input)
    if not ok then
        return nil, result
    else
        return result
    end
end

---Decodes bitser data from an external file path and returns the result if successful, otherwise returns nil and an error message.
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
-- If path is specified, the bitser string is written out to a file at path. Returns true if successful, otherwise returns nil and an error message. Note that LOVE2D is required to write out to a file.
-- If path is not specified, the input is encoded. The result is returned if successful, otherwise returns nil and an error message.
local function bitserEncoder(input, path)
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