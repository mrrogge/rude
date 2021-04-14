local contract = require('rude._contract')
local RudeObject = require('rude.RudeObject')

local DataContext = RudeObject:subclass('DataContext')

function DataContext:initialize()
    contract('rt', self)
    self.com = {}
    self.classes = {}
    self.functions = {}
    self.assets = {}
    self.assetLoaders = {}
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

function DataContext:registerAssetLoader(id, loader)
    contract('rt,rs,rf|t')
    self.assetLoaders[id] = loader
    return self
end

function DataContext:getAsset(loaderId, assetId, forceLoad)
    contract('rt,rs,rany,b')
    self.assets[loaderId] = self.assets[loaderId] or {}
    if forceLoad or self.assets[loaderId][assetId] == nil then
        if not self.assetLoaders[loaderId] then
            error(('No asset loader defined for ID %s'):format(loaderId))
        end
        self.assets[loaderId][assetId] = self.assetLoaders[loaderId](assetId)
    end
    return self.assets[loader]
end

return DataContext