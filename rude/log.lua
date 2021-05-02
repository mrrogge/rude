local class = require('middleclass')

local function print_(payload)
    print(payload)
end

local loveWarningFlag = false

local function loveWriteFile(payload, path)
    if love and love.filesystem and love.filesystem.write then
        local ok, err = love.filesystem.write(path, payload)
        if not ok then
            print(('LOG ERROR: %s'):format(err))
        end
    else
        if not loveWarningFlag then
            print('LOG ERROR: love api not found, cannot write to external file.')
            loveWarningFlag = true
        end
    end
end

local Logger = class('Logger')

function Logger:initialize(fnc, minSeverity)
    self.fnc = fnc or print_
    self.minSeverity = minSeverity or log.WARNING
    return self
end

function Logger:log(payload, ...)
    if type(payload) == 'table' and type(payload.severity) == 'number'
    and payload.severity <= self.minSeverity
    then
        local ok, err = pcall(self.fnc, payload, ...)
        if not ok then
            print('LOG ERROR: %s', err)
        end
    end
    return self
end

local log = {
    Logger=Logger,
    FATAL=1,
    SEVERE=2,
    WARNING=3,
    INFO=4,
    DEBUG=5
}

return log