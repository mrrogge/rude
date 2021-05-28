---Provides additional context and add-ons for engines.
-- @classmod DataContext

local contract = require('rude._contract')
local RudeObject = require('rude.RudeObject')
local Exception = require('rude.Exception')
local MissingComClassException = require('rude.MissingComClassException')
local logging = require('rude.logging')

local DataContext = RudeObject:subclass('DataContext')

---Initializes an instance.
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
-- 
-- By registering a component class to a specific ID, an instance of that class can automatically be built when importing entity data.
-- @tparam string id The ID for the component class
-- @tparam class class the component class
-- @return the DataContext instance
function DataContext:registerComClass(id, class)
    contract('rt,rs,rt')
    self.com[id] = class
    self.classes[class] = true
    return self
end

---Returns the registered component class for a given id.
-- @tparam string id The ID for the component class.
-- @return the component class if it exists, otherwise nil and an exception
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
-- 
-- This maps a custom Lua function to a string, allowing the function to be referenced from within component data. This provides a way to change logic dynamically by simply changing data values.
-- @tparam string id the ID for the function
-- @tparam function fnc the function
-- @return the DataContext instance
function DataContext:registerFunction(id, fnc)
    contract('rt,rs,rf')
    self.functions[id] = fnc
    return self
end

---Returns a registered function for a given id.
-- @tparam string id the ID for the function
-- @return the function if it exists, otherwise nil and an exception
function DataContext:getFunction(id)
    contract('rt,rs')
    local fnc = self.functions[id]
    if not fnc then
        return nil, Exception(('No function registered for ID "%s".'):format(id))
    end
    return fnc
end

---Registers an asset loader to a given id.
-- 
-- Asset loaders are functions that accept a string argument and build a static asset such as an image or audio clip. Asset loaders are assumed to be deterministic, such that a given id value always yields an equivalent corresponding asset.
-- @tparam string id the ID for the asset loader function
-- @tparam function loader the asset loader function
-- @return the DataContext instance
function DataContext:registerAssetLoader(id, loader)
    contract('rt,rs,rf|t')
    self.assetLoaders[id] = loader
    return self
end

---Returns an asset loader for a given id.
-- @tparam string id the ID for the asset loader function
-- @return the asset loader function if it exists, otherwise nil and an exception
function DataContext:getAssetLoader(id)
    contract('rt,rs')
    local loader = self.assetLoaders[id]
    if not loader then
        return nil, Exception(('No asset loader defined for ID %s.'):format(id))
    end
    return loader
end

---Returns an asset for a given loaderId and assetId.
-- 
-- Assets are cached so that repeat calls return the previously built asset. When forceLoad is true, the asset will be built again even if it was already built.
-- @tparam string loaderId the ID for the asset loader function
-- @tparam any assetId the ID passed to the asset loader function
-- @tparam[opt] bool forceLoad forces asset to be re-loaded when true
-- @return the asset if the loader is valid, otherwise nil and an exception
function DataContext:getAsset(loaderId, assetId, forceLoad)
    contract('rt,rs,rany,b')
    self.assets[loaderId] = self.assets[loaderId] or {}
    if forceLoad or self.assets[loaderId][assetId] == nil then
        if not self.assetLoaders[loaderId] then
            return nil, Exception(('No asset loader defined for ID %s'):format(loaderId))
        end
        self.assets[loaderId][assetId] = self.assetLoaders[loaderId](assetId)
    end
    return self.assets[loaderId][assetId]
end

---Releases all asset references for a given loaderId.
-- @tparam string loaderId the ID for the asset loader function
-- @return the DataContext instance
function DataContext:releaseAssets(loaderId)
    contract('rt,rs')
    if self.assets[loaderId] then
        for k, v in pairs(self.assets[loaderId]) do
            self.assets[loaderId][k] = nil
        end
    end
    return self
end

---Registers a data decoder to a given id.
-- 
-- Data decoders are functions that accept an input and build a corresponding Lua table of data. These are used by the Engine:importData() function to read data into the engine.
-- @tparam string id the ID for the data decoder
-- @tparam function|functable decoder the data decoder
-- @return the DataContext instance
function DataContext:registerDataDecoder(id, decoder)
    contract('rt,rs,rf|t', self, id, decoder)
    self.dataDecoders[id] = decoder
    return self
end

---Returns a data decoder for a given id.
-- @tparam string id the ID for the data decoder
-- @return the data decoder if it exists, otherwise nil and an exception
function DataContext:getDataDecoder(id)
    contract('rt,rs')
    if not self.dataDecoders[id] then
        return nil, Exception(('No data decoder registered for ID %s.'):format(id))
    end
    return self.dataDecoders[id]
end

---Registers a data encoder to a given id.
-- 
-- Data encoders are functions that accept an input and an optional string path. If path is not specified, encoders should return a deterministic string representation of the input. If path is specified, then the encoder can use this path to write out to an external file. These are used by Engine:exportData() to write data out from the engine.
-- @tparam string id the ID for the data encoder
-- @tparam function|functable encoder the data encoder
-- @return the DataContext instance
function DataContext:registerDataEncoder(id, encoder)
    contract('rt,rs,rf|t', self, id, encoder)
    self.dataEncoders[id] = encoder
    return self
end

---Returns a data encoder for a given id.
-- @tparam string id the ID for the data encoder
-- @return the data encoder if it exists, otherwise nil and an exception
function DataContext:getDataEncoder(id)
    contract('rt,rs')
    if not self.dataEncoders[id] then
        return nil, Exception(('No data encoder registered for ID %s.'):format(id))
    end
    return self.dataEncoders[id]
end

---Builds a new `rude.logging.Logger` instance and registers it to a given id.
-- @tparam string id the ID for the logger
-- @tparam function fnc the log function
-- @tparam number minSeverity the minimum severity value for the logger
-- @return the logger
function DataContext:registerLogger(id, fnc, minSeverity)
    contract('rt,rs,f,n')
    self.loggers[id] = logging.Logger(fnc, minSeverity)
    return self.loggers[id]
end

---Logs a payload using a given logger id.
-- @tparam string id the ID for the logger
-- @tparam any payload the data sent to the logger
-- @param ... additional parameters passed to the logger function
-- @return true if logging was successful, other nil and an exception
function DataContext:log(id, payload, ...)
    if self.loggers[id] then
        self.loggers[id]:log(payload, ...)
    else
        return nil, Exception(('No logger defined for ID %s.'):format(id))
    end
    return true
end

return DataContext
