local Engine = require('rude.Engine')
local plugin = require('rude.plugins.bitserPlugin')   

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
                -- NOTE: for some reason I'm having trouble with clearing love and jit temporarily within an insulate block. I may be misunderstanding how these are supposed to work. For the time being, I am directly clearing the APIs from the _G table and adding them back in at the end of the block so that the next block of tests aren't affected.
                local loveOld = _G.love
                setup(function()
                    _G.love = nil
                end)

                it('using plugin does not error', function()
                    assert.has_no.errors(function()
                        engine:usePlugin(plugin)
                    end)
                end)

                it('does not register bitser-file-love data decoder', function()
                    engine:usePlugin(plugin)
                    assert.is_not.truthy(engine:getDataDecoder('bitser-file-love'))
                end)

                teardown(function()
                    _G.love = loveOld
                end)
            end)
        end)

        insulate('and when bitser module is missing', function()
            --TODO: I'm not sure how to test this. If spec/lib/bitser.lua exists, then the plugin will always find it when it does the internal require call. I can't import the module, then remove its bitser reference after-the-fact. The only options seem to be removing bitser.lua manually, or messing with the require path. For now, I'll just mark these tests as skipped.
            it('#skip raises an error', function()
                assert.has.errors(function()
                    engine:usePlugin(plugin)
                end)
            end)
        end)
    end)

    insulate('without jit', function()
        local jitOld = _G.jit
        setup(function()
            _G.jit = nil
        end)

        it('raises an error', function()
            assert.has.errors(function()
                engine:usePlugin(plugin)
            end)
        end)

        teardown(function()
            _G.jit = jitOld
        end)
    end)
end)