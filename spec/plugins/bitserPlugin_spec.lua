local Engine = require('rude.Engine')

describe('#bitser plugins.bitserPlugin', function()
    local engine
    before_each(function()
        engine = Engine()
    end)

    insulate('#jit with jit', function()
        --check that jit exists for these tests
        if not jit then
            error('lua-jit is required for these tests')
        end

        insulate('#bitser and when bitser module exists', function()
            local plugin = require('rude.plugins.bitserPlugin')
            --explicitly require bitser to make sure it exists for these tests
            require('bitser')

            it('registers bitser-string data decoder', function()
                engine:usePlugin(plugin)
                assert.is.truthy(engine:getDataDecoder('bitser-string'))
            end)

            it('registers bitser data encoder', function()
                engine:usePlugin(plugin)
                assert.is.truthy(engine:getDataEncoder('bitser'))
            end)

            it('allows encoding/decoding via bitser', function()
                engine:usePlugin(plugin)
                local encoded = engine:getDataEncoder('bitser')('test')
                local decoded = engine:getDataDecoder('bitser-string')(encoded)
                assert.is.equal(decoded, 'test')
            end)

            insulate('#love and with LOVE', function()
                it('using plugin does not error', function()
                    assert.has_no.errors(function()
                        engine:usePlugin(plugin)
                    end)
                end)

                it('registers bitser-file-love data decoder', function()
                    plugin = require('rude.plugins.bitserPlugin')
                    engine:usePlugin(plugin)
                    assert.is.truthy(engine:getDataDecoder('bitser-file-love'))
                end)

                it('allows writing encoded data to file', function()
                    engine:usePlugin(plugin)
                    assert.is.truthy(engine:getDataEncoder('bitser')('test', 'test.txt'))
                end)

                it('calling bitser-file-love data decoder calls bitser.loadLoveFile()', function()
                    engine:usePlugin(plugin)
                    local bitser = require('bitser')
                    local s = stub(bitser, 'loadLoveFile')
                    engine:getDataDecoder('bitser-file-love')('test.txt')
                    assert.stub(s).was_called()
                end)
            end)
    
            insulate('and without LOVE', function()
                -- NOTE: for some reason `love = nil` does not work, I need to clear it on _G explicitly. This may be due to how insulate() works, or something with the strict library, but I'm not sure.
                _G.love = nil

                it('using plugin does not error', function()
                    assert.has_no.errors(function()
                        engine:usePlugin(plugin)
                    end)
                end)

                it('does not register bitser-file-love data decoder', function()
                    engine:usePlugin(plugin)
                    assert.is_not.truthy(engine:getDataDecoder('bitser-file-love'))
                end)
            end)
        end)

        insulate('and when bitser module is missing', function()
            --TODO: I'm not sure how to test this. If spec/lib/bitser.lua exists, then the plugin will always find it when it does the internal require call. I can't import the module, then remove its bitser reference after-the-fact. The only options seem to be removing bitser.lua manually, or messing with the require path. For now, I'll just mark these tests as pending.
            local plugin = require('rude.plugins.bitserPlugin')

            pending('raises an error', function()
                assert.has.errors(function()
                    engine:usePlugin(plugin)
                end)
            end)
        end)
    end)

    insulate('without jit', function()
        --TODO: for some reason clearing the jit table causes this test to error and I'm not sure why. For now I'm setting it to pending.
        _G.jit = nil
        local plugin = require('rude.plugins.bitserPlugin')

        it('raises an error', function()
            assert.has.errors(function()
                engine:usePlugin(plugin)
            end)
        end)
    end)
end)