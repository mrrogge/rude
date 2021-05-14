local Engine = require('rude.Engine')
local plugin = require('rude.plugins.lovePlugin')

describe('plugins.lovePlugin', function()
    local engine

    before_each(function()
        engine = Engine()
    end)

    insulate('with LOVE', function()
        it('when version < 11.0 raises an error', function()
            getVersionOld = love.getVersion
            love.getVersion = function() return 10, 0 end
            assert.has.errors(function()
                engine:usePlugin(plugin)
            end)
            love.getVersion = getVersionOld
        end)

        it('when version >= 11.0 does not error', function()
            assert.has_no.errors(function()
                engine:usePlugin(plugin)
            end)
        end)

        it('registers an image asset loader', function()
            engine:usePlugin(plugin)
            assert.is.truthy(engine:getAssetLoader('image'))
        end)

        it('registers a font asset loader', function()
            engine:usePlugin(plugin)
            assert.is.truthy(engine:getAssetLoader('font'))
        end)

        it('extends engine with a love table', function()
            engine:usePlugin(plugin)
            assert.is.truthy(engine.love)
        end)

        it('extends engine with a love.attach method', function()
            engine:usePlugin(plugin)
            assert.is.truthy(engine.love.attach)
        end)

        it('extends engine with a love.detach method', function()
            engine:usePlugin(plugin)
            assert.is.truthy(engine.love.detach)
        end)

        describe('love.attach()', function()
            it('allows engine:load() to be called via love.load()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'load')
                love.load()
                assert.spy(engine.load).was.called()
            end)

            it('allows original love.load() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'load')
                engine.love.attach()
                love.load()
                assert.spy(s).was.called()
                s:revert()
            end)

            it('allows engine:update() to be called via love.update()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'update')
                love.update(0)
                assert.spy(engine.update).was.called()
            end)

            it('allows original love.update() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'update')
                engine.love.attach()
                love.update(0)
                assert.spy(s).was.called()
                s:revert()
            end)

            it('allows engine:draw() to be called via love.draw()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'draw')
                love.draw()
                assert.spy(engine.draw).was.called()
            end)

            it('allows original love.draw() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'draw')
                engine.love.attach()
                love.draw()
                assert.spy(s).was.called()
                s:revert()
            end)
            
            it('allows engine:keyPressed() to be called via love.keypressed()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'keyPressed')
                love.keypressed('','',false)
                assert.spy(engine.keyPressed).was.called()
            end)

            it('allows original love.keypressed() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'keypressed')
                engine.love.attach()
                love.keypressed('','',false)
                assert.spy(s).was.called()
                s:revert()
            end)

            it('allows engine:keyReleased() to be called via love.keyreleased()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'keyReleased')
                love.keyreleased('','')
                assert.spy(engine.keyReleased).was.called()
            end)

            it('allows original love.keyreleased() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'keyreleased')
                engine.love.attach()
                love.keyreleased('','')
                assert.spy(s).was.called()
                s:revert()
            end)

            it('allows engine:mouseMoved() to be called via love.mousemoved()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'mouseMoved')
                love.mousemoved(0,0,0,0,false)
                assert.spy(engine.mouseMoved).was.called()
            end)

            it('allows original love.mousemoved() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'mousemoved')
                engine.love.attach()
                love.mousemoved(0,0,0,0,false)
                assert.spy(s).was.called()
                s:revert()
            end)

            it('allows engine:mousePressed() to be called via love.mousepressed()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'mousePressed')
                love.mousepressed(0,0,0,false,1)
                assert.spy(engine.mousePressed).was.called()
            end)

            it('allows original love.mousepressed() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'mousepressed')
                engine.love.attach()
                love.mousepressed(0,0,0,false,1)
                assert.spy(s).was.called()
                s:revert()
            end)

            it('allows engine:mouseReleased() to be called via love.mousereleased()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'mouseReleased')
                love.mousereleased(0,0,0,false,1)
                assert.spy(engine.mouseReleased).was.called()
            end)

            it('allows original love.mousereleased() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'mousereleased')
                engine.love.attach()
                love.mousereleased(0,0,0,false,1)
                assert.spy(s).was.called()
                s:revert()
            end)

            it('allows engine:wheelMoved() to be called via love.wheelmoved()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'wheelMoved')
                love.wheelmoved(0,0)
                assert.spy(engine.wheelMoved).was.called()
            end)

            it('allows original love.wheelmoved() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'wheelmoved')
                engine.love.attach()
                love.wheelmoved(0,0)
                assert.spy(s).was.called()
                s:revert()
            end)
        end)

        describe('detach()', function()
            it('prevents engine:load() from being called via love.load()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'load')
                engine.love.detach()
                love.load()
                assert.spy(engine.load).was_not.called()
            end)

            it('allows original love.load() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'load')
                engine.love.attach()
                engine.love.detach()
                love.load()
                assert.spy(s).was.called()
                s:revert()
            end)

            it('prevents engine:update() from being called via love.update()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'update')
                engine.love.detach()
                love.update(0)
                assert.spy(engine.update).was_not.called()
            end)

            it('allows original love.update() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'update')
                engine.love.attach()
                engine.love.detach()
                love.update(0)
                assert.spy(s).was.called()
                s:revert()
            end)

            it('prevents engine:draw() from being called via love.draw()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'draw')
                engine.love.detach()
                love.draw()
                assert.spy(engine.draw).was_not.called()
            end)

            it('allows original love.draw() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'draw')
                engine.love.attach()
                engine.love.detach()
                love.draw()
                assert.spy(s).was.called()
                s:revert()
            end)

            it('prevents engine:keyPressed() from being called via love.keypressed()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'keyPressed')
                engine.love.detach()
                love.keypressed('','',false)
                assert.spy(engine.keyPressed).was_not.called()
            end)

            it('allows original love.keypressed() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'keypressed')
                engine.love.attach()
                engine.love.detach()
                love.keypressed('','',false)
                assert.spy(s).was.called()
                s:revert()
            end)

            it('prevents engine:keyReleased() from being called via love.keyreleased()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'keyReleased')
                engine.love.detach()
                love.keyreleased('','')
                assert.spy(engine.keyReleased).was_not.called()
            end)

            it('allows original love.keyreleased() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'keyreleased')
                engine.love.attach()
                engine.love.detach()
                love.keyreleased('','')
                assert.spy(s).was.called()
                s:revert()
            end)

            it('prevents engine:mouseMoved() from being called via love.mousemoved()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'mouseMoved')
                engine.love.detach()
                love.mousemoved(0,0,0,0,false)
                assert.spy(engine.mouseMoved).was_not.called()
            end)

            it('allows original love.mousemoved() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'mousemoved')
                engine.love.attach()
                engine.love.detach()
                love.mousemoved(0,0,0,0,false)
                assert.spy(s).was.called()
                s:revert()
            end)

            it('prevents engine:mousePressed() from being called via love.mousepressed()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'mousePressed')
                engine.love.detach()
                love.mousepressed(0,0,0,false,1)
                assert.spy(engine.mousePressed).was_not.called()
            end)

            it('allows original love.mousepressed() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'mousepressed')
                engine.love.attach()
                engine.love.detach()
                love.mousepressed(0,0,0,false,1)
                assert.spy(s).was.called()
                s:revert()
            end)

            it('prevents engine:mouseReleased() from being called via love.mousereleased()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'mouseReleased')
                engine.love.detach()
                love.mousereleased(0,0,0,false,1)
                assert.spy(engine.mouseReleased).was_not.called()
            end)

            it('allows original love.mousereleased() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'mousereleased')
                engine.love.attach()
                engine.love.detach()
                love.mousereleased(0,0,0,false,1)
                assert.spy(s).was.called()
                s:revert()
            end)

            it('prevents engine:wheelMoved() from being called via love.wheelmoved()', function()
                engine:usePlugin(plugin)
                engine.love.attach()
                spy.on(engine, 'wheelMoved')
                engine.love.detach()
                love.wheelmoved(0,0)
                assert.spy(engine.wheelMoved).was_not.called()
            end)

            it('allows original love.wheelmoved() to still be called', function()
                engine:usePlugin(plugin)
                local s = spy.on(love, 'wheelmoved')
                engine.love.attach()
                engine.love.detach()
                love.wheelmoved(0,0)
                assert.spy(s).was.called()
                s:revert()
            end)
        end)
    end)

    insulate('without LOVE', function()
        local loveOld = _G.love
        setup(function()
            _G.love = nil
        end)

        it('raises an error', function()
            assert.has.errors(function()
                engine:usePlugin(plugin)
            end)
        end)

        teardown(function()
            _G.love = loveOld
        end)
    end)
 

    -- describe('detach()', function()
    --     it('prevents engine callbacks from being called through LOVE', function()
    --         local e = Engine()
    --         e:attach()
    --         e:detach()

    --         spy.on(e, 'load')
    --         love.load()
    --         assert.spy(e.load).was_not.called()
    --         e.load:revert()

    --         spy.on(e, 'update')
    --         love.update(1)
    --         assert.spy(e.update).was_not.called()
    --         e.update:revert()

    --         spy.on(e, 'draw')
    --         love.draw()
    --         assert.spy(e.draw).was_not.called()
    --         e.draw:revert()

    --         spy.on(e, 'keypressed')
    --         love.keypressed('','',false)
    --         assert.spy(e.keypressed).was_not.called()
    --         e.keypressed:revert()

    --         spy.on(e, 'keyreleased')
    --         love.keyreleased('','')
    --         assert.spy(e.keyreleased).was_not.called()
    --         e.keyreleased:revert()
            
    --         spy.on(e, 'mousemoved')
    --         love.mousemoved(0,0,0,0,false)
    --         assert.spy(e.mousemoved).was_not.called()
    --         e.mousemoved:revert()

    --         spy.on(e, 'mousepressed')
    --         love.mousepressed(0,0,0,false,1)
    --         assert.spy(e.mousepressed).was_not.called()
    --         e.mousepressed:revert()

    --         spy.on(e, 'mousereleased')
    --         love.mousereleased(0,0,0,false,1)
    --         assert.spy(e.mousereleased).was_not.called()
    --         e.mousereleased:revert()

    --         spy.on(e, 'wheelmoved')
    --         love.wheelmoved(0,0)
    --         assert.spy(e.wheelmoved).was_not.called()
    --         e.wheelmoved:revert()
    --     end)
    --     it('allows original LOVE callbacks to be called', function()
    --         local e = Engine()
    --         local initCallbacks = {
    --             load=spy.on(love, 'load'),
    --             update=spy.on(love, 'update'),
    --             draw=spy.on(love, 'draw'),
    --             keypressed=spy.on(love, 'keypressed'),
    --             keyreleased=spy.on(love, 'keyreleased'),
    --             mousemoved=spy.on(love, 'mousemoved'),
    --             mousepressed=spy.on(love, 'mousepressed'),
    --             mousereleased=spy.on(love, 'mousereleased'),
    --             wheelmoved=spy.on(love, 'wheelmoved')
    --         }
    --         e:attach()
    --         e:detach()
            
    --         love.load()
    --         assert.spy(initCallbacks.load).was.called()
    --         initCallbacks.load:revert()

    --         love.update(1)
    --         assert.spy(initCallbacks.update).was.called()
    --         initCallbacks.update:revert()

    --         love.draw()
    --         assert.spy(initCallbacks.draw).was.called()
    --         initCallbacks.draw:revert()

    --         love.keypressed('','',false)
    --         assert.spy(initCallbacks.keypressed).was.called()
    --         initCallbacks.keypressed:revert()

    --         love.keyreleased('','')
    --         assert.spy(initCallbacks.keyreleased).was.called()
    --         initCallbacks.keyreleased:revert()      
            
    --         love.mousemoved(0,0,0,0,false)
    --         assert.spy(initCallbacks.mousemoved).was.called()
    --         initCallbacks.mousemoved:revert()

    --         love.mousepressed(0,0,0,false,1)
    --         assert.spy(initCallbacks.mousepressed).was.called()
    --         initCallbacks.mousepressed:revert()

    --         love.mousereleased(0,0,0,false,1)
    --         assert.spy(initCallbacks.mousereleased).was.called()
    --         initCallbacks.mousereleased:revert()

    --         love.wheelmoved(0,0)
    --         assert.spy(initCallbacks.wheelmoved).was.called()
    --         initCallbacks.wheelmoved:revert()
    --     end)
    -- end)
end)