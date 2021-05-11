---An exception object.
-- Exceptions can be used to identify "exceptional" branches in code. They use debug.getinfo() to identify the calling source and line of code, which makes it easy to log the exception or raise it as an error. Note that Exceptions do not automatically create errors, they are just plain objects.

local class = require('middleclass')

local Exception = class('Exception')

function Exception:initialize(msg, level)
    self.msg = msg
    level = level or 2
    local info = debug.getinfo(level, 'Sl') --get the source and current line of the calling function
    if info then
        if info.what == 'C' then
            self.src, self.line = 'c func', '??'
        else
            self.src, self.line = info.short_src, info.currentline
        end
    end
    return self
end

function Exception:toString()
    return ('[%s:%s]:%s'):format(self.src, self.line, self.msg)
end

Exception.__tostring = Exception.toString

return Exception