local contract = require('rude._contract')
local RudeObject = require('rude.RudeObject')
local Exception = require('rude.Exception')
local MissingComClassException = require('rude.MissingComClassException')
local log = require('rude.log')

local DataContext = RudeObject:subclass('DataContext')

function DataContext:initialize()
    contract('rt', self)
    self.com = {}
    self.classes = {}
    self.functions = {}
    self.assets = {}
    self.assetLoaders = {}
    self.dataDecoders = {}
    self.dataEncoders = {}
    self.loggers = {}
    self.currentLogger = nil
    return self
end

---Registers a component class.
-- By registering a component class to a specific ID, an instance of that class can automatically be built when importing entity data.
function DataContext:registerComClass(id, class)
    contract('rt,rs,rt')
    self.com[id] = class
    self.classes[class] = true
    return self
end

---Returns the registers component class for a given id.
-- If no class exists, returns nil and an error message.
function DataContext:getComClass(id)
    contract('rt,rs')
    local class = self.com[id]
    if not class then
        return nil, MissingComClassException(id)
    end
    return class
end

function DataContext:registerClass(class)
    contract('rt,rt')
    self.classes[class] = true
    return self
end

---Registers a function to a given id.
-- By registering a function, systems can call them dynamically based on components referencing their ids.
function DataContext:registerFunction(id, fnc)
    contract('rt,rs,rf')
    self.functions[id] = fnc
    return self
end

---Returns a registered function for a given id.
-- If no function exists, returns nil and an error message.
function DataContext:getFunction(id)
    contract('rt,rs')
    local fnc = self.functions[id]
    if not fnc then
        return nil, Exception(('No function registered for ID "%s".'):format(id))
    end
    return fnc
end

---Registers an asset loader to a given id.
-- Asset loaders are functions that accept a string argument and build a static asset such as an image or audio clip.
function DataContext:registerAssetLoader(id, loader)
    contract('rt,rs,rf|t')
    self.assetLoaders[id] = loader
    return self
end

---Returns an asset loader for a given id.
-- If loader does not exist, returns nil and an exception.
function DataContext:getAssetLoader(id)
    contract('rt,rs')
    local loader = self.assetLoaders[id]
    if not loader then
        return nil, Exception(('No asset loader defined for ID %s.'):format(id))
    end
    return loader
end

---Returns an asset for a given loaderId and assetId.
-- Assets are cached so that repeat calls return the previously built asset. When forceLoad is true, the asset will be built again even if it was already built.
function DataContext:getAsset(loaderId, assetId, forceLoad)
    contract('rt,rs,rany,b')
    self.assets[loaderId] = self.assets[loaderId] or {}
    if forceLoad or self.assets[loaderId][assetId] == nil then
        if not self.assetLoaders[loaderId] then
            return nil, Exception(('No asset loader defined for ID %s'):format(loaderId))
        end
        self.assets[loaderId][assetId] = self.assetLoaders[loaderId](assetId)
    end
    return self.assets[loaderId]
end

---Releases all asset references for a given loaderId.
function DataContext:releaseAssets(loaderId)
    contract('rt,rs')
    if self.assets[loaderId] then
        for k, v in pairs(self.assets[loaderId]) do
            self.assets[loaderId][k] = nil
        end
    end
end

---Registers a data decoder to a given id.
-- Data decoders are functions that accept an input and build a corresponding Lua table of data. These are used by the Engine:importData() function to read data into the engine.
function DataContext:registerDataDecoder(id, decoder)
    contract('rt,rs,rf|t', self, id, decoder)
    self.dataDecoders[id] = decoder
    return self
end

function DataContext:getDataDecoder(id)
    contract('rt,rs')
    if not self.dataDecoders[id] then
        return nil, ('No data decoder registered for ID %s.'):format(id)
    end
    return self.dataDecoders[id]
end

---Registers a data encoder to a given id.
-- Data encoders are functions that accept an input and an optional string path. If path is not specified, encoders should return a string representation of the input. If path is specified, then the string value is written out to an external file at path. These are used by Engine:exportData() to write data out from the engine.
function DataContext:registerDataEncoder(id, encoder)
    contract('rt,rs,rf|t', self, id, encoder)
    self.dataEncoders[id] = encoder
    return self
end

function DataContext:getDataEncoder(id)
    contract('rt,rs')
    if not self.dataEncoders[id] then
        return nil, ('No data encoder registered for ID %s.'):format(id)
    end
    return self.dataEncoders[id]
end

function DataContext:registerLogger(id, fnc, minSeverity)
    self.loggers[id] = log.Logger(fnc, minSeverity)
    return self.loggers[id]
end

function DataContext:log(id, payload, ...)
    if self.loggers[id] then
        self.loggers[id]:log(payload, ...)
    else
        return nil, Exception(('No logger defined for ID %s.'):format(id))
    end
    return true
end

return DataContext
