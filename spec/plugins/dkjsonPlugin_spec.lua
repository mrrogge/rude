local Engine = require('rude.Engine')
local plugin = require('rude.plugins.dkjsonPlugin')

describe('dkjsonPlugin', function()
    local engine

    before_each(function()
        engine = Engine()
    end)

    describe('with dkjson module', function()
        local dkjson = require('dkjson')

        it('registers dkjson-string data decoder', function()
            engine:usePlugin(plugin)
            assert.is.truthy(engine:getDataDecoder('dkjson-string'))
        end)
        it('registers dkjson data encoder', function()
            engine:usePlugin(plugin)
            assert.is.truthy(engine:getDataEncoder('dkjson'))
        end)

        describe('dkjson-string data decoder', function()
            it('passes input to dkjson.decode', function()
                spy.on(dkjson, 'decode')
                engine:usePlugin(plugin)
                engine:getDataDecoder('dkjson-string')('test')
                assert.spy(dkjson.decode).was.called_with('test')
            end)
        end)

        describe('dkjson data encoder', function()
            it('when passed just an input passes it to dkjson.encode()', function()
                spy.on(dkjson, 'encode')
                engine:usePlugin(plugin)
                engine:getDataEncoder('dkjson')('test')
                assert.spy(dkjson.encode).was.called_with('test', match.any())
            end)
        end)

        describe('and with LOVE', function()
            it('registers dkjson-file-love data decoder', function()
                engine:usePlugin(plugin)
                assert.is.truthy(engine:getDataDecoder('dkjson-file-love'))
            end)
            
            describe('dkjson-file-love data decoder', function()
                it('passes input to love.filesystem.read()', function()
                    spy.on(love.filesystem, 'read')
                    engine:usePlugin(plugin)
                    engine:getDataDecoder('dkjson-file-love')('test')
                    assert.spy(love.filesystem.read).was.called_with('test')
                end)
            end)

            describe('dkjson data encoder', function()
                it('when passed an input and a path passes the input to dkjson.encode()', function()
                    spy.on(dkjson, 'encode')
                    engine:usePlugin(plugin)
                    engine:getDataEncoder('dkjson')('test', 'path/to/file.txt')
                    assert.spy(dkjson.encode).was.called_with('test', match.any())
                end)
            end)
        end)

        describe('and without LOVE', function()
            local loveOld = _G.love
            setup(function()
                _G.love = nil
            end)

            it('using plugin does not error', function()
                assert.has_no.errors(function()
                    engine:usePlugin(plugin)
                end)
            end)

            it('does not register dkjson-file-love data decoder', function()
                engine:usePlugin(plugin)
                assert.is_not.truthy(engine:getDataDecoder('dkjson-file-love'))
            end)

            teardown(function()
                _G.love = loveOld
            end)
        end)
    end)
end)