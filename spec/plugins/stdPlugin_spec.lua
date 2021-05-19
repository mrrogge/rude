local Engine = require('rude.Engine')
local plugin = require('rude.plugins.stdPlugin')
local util = require('rude.util')

describe('stdPlugin', function()
    local engine

    before_each(function()
        engine = Engine()
        --note that engine instances should automatically apply stdPlugin on initialization. This is covered in a separate test.
    end)

    it('registers require data decoder', function()
        assert.is.truthy(engine:getDataDecoder('require'))
    end)

    it('registers lua-string data decoder', function()
        assert.is.truthy(engine:getDataDecoder('lua-string'))
    end)   

    it('registers lua data encoder', function()
        assert.is.truthy(engine:getDataDecoder('require'))
    end)

    describe('require data decoder', function()

    end)

    describe('lua-string data decoder', function()

    end)

    describe('lua data encoder', function()
        it('passes input to rude.util.serializeToLua()', function()
            spy.on(util, 'serializeToLua')
            engine:getDataEncoder('lua')('test')
            assert.spy(util.serializeToLua).was.called_with('test')
            util.serializeToLua:revert()
        end)
    end)
end)