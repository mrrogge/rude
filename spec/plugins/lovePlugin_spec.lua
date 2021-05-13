local Engine = require('rude.Engine')

describe('plugins.lovePlugin', function()
    local engine

    before_each(function()
        engine = Engine()
    end)

    insulate('with LOVE', function()
        local plugin = require('rude.plugins.lovePlugin')
    end)

    insulate('without LOVE', function()
        _G.love = nil
        local plugin = require('rude.plugins.lovePlugin')

        it('raises an error', function()
            assert.has.errors(function()
                engine:usePlugin(plugin)
            end)
        end)
    end)
    -- describe('attach()', function()
    --     it('allows engine callbacks to be called from LOVE callbacks', function()
    --         local e = Engine()
    --         e:pushScene(Scene(e))
    --         e:attach()

    --         spy.on(e, 'load')
    --         love.load()
    --         assert.spy(e.load).was.called()
    --         e.load:revert()

    --         spy.on(e, 'update')
    --         love.update(1)
    --         assert.spy(e.update).was.called()
    --         e.update:revert()

    --         spy.on(e, 'draw')
    --         love.draw()
    --         assert.spy(e.draw).was.called()
    --         e.draw:revert()

    --         spy.on(e, 'keypressed')
    --         love.keypressed('','',false)
    --         assert.spy(e.keypressed).was.called()
    --         e.keypressed:revert()

    --         spy.on(e, 'keyreleased')
    --         love.keyreleased('','')
    --         assert.spy(e.keyreleased).was.called()
    --         e.keyreleased:revert()

    --         spy.on(e, 'mousemoved')
    --         love.mousemoved(0,0,0,0,false)
    --         assert.spy(e.mousemoved).was.called()
    --         e.mousemoved:revert()

    --         spy.on(e, 'mousepressed')
    --         love.mousepressed(0,0,0,false,1)
    --         assert.spy(e.mousepressed).was.called()
    --         e.mousepressed:revert()
            
    --         spy.on(e, 'mousereleased')
    --         love.mousereleased(0,0,0,false,1)
    --         assert.spy(e.mousereleased).was.called()
    --         e.mousereleased:revert()

    --         spy.on(e, 'wheelmoved')
    --         love.wheelmoved(0,0)
    --         assert.spy(e.wheelmoved).was.called()
    --         e.wheelmoved:revert()
    --     end)
    --     it('once complete, original LOVE callbacks are still called', function()
    --         local e = Engine()
    --         e:pushScene(Scene(e))
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