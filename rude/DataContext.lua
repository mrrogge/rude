local contract = require('rude._contract')
local RudeObject = require('rude.RudeObject')

local DataContext = RudeObject:subclass('DataContext')

function DataContext:initialize()
    contract('rt', self)
    self.com = {}
    self.classes = {}
    self.functions = {}
    return self
end

function DataContext:registerComClass(id, class)
    contract('rt,rs,rt')
    self.com[id] = class
    self.classes[class] = true
    return self
end

function DataContext:getComClass(id)
    contract('rt,rs')
    local class = self.com[id]
    if not class then
        return nil, ('No component class registered for ID "%s".'):format(id)
    end
    return class
end

function DataContext:registerClass(class)
    contract('rt,rt')
    self.classes[class] = true
    return self
end

function DataContext:registerFunction(id, fnc)
    contract('rt,rs,rf')
    self.functions[id] = fnc
    return self
end

function DataContext:getFunction(id)
    contract('rt,rs')
    local fnc = self.functions[id]
    if not fnc then
        return nil, ('No function registered for ID "%s".'):format(id)
    end
    return fnc
end

return DataContext