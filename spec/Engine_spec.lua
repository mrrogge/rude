local class = require('middleclass')
local Engine = require('rude.Engine')
local Scene = require('rude.Scene')
local bitser = require('rude.lib.bitser')

describe('an Engine instance:', function()
    local e
    --Create a data class for testing
    local TestClass = class('TestClass')
    before_each(function()
        e = Engine()
        e:registerDataClass('TestClass', TestClass)
    end)
    it('exposes the public modules', function()
        assert.is.equal(e.alert, require('rude.alert'))
        assert.is.equal(e.assert, require('rude.assert'))
        assert.is.equal(e.Engine, require('rude.Engine'))
        assert.is.equal(e.EventEmitterMixin, require('rude.EventEmitterMixin'))
        assert.is.equal(e.graphics, require('rude.graphics'))
        assert.is.equal(e.PoolableMixin, require('rude.PoolableMixin'))
        assert.is.equal(e.RudeObject, require('rude.RudeObject'))
        assert.is.equal(e.Scene, require('rude.Scene'))
        assert.is.equal(e.Sys, require('rude.Sys'))
        assert.is.equal(e.TablePool, require('rude.TablePool'))
        assert.is.equal(e.util, require('rude.util'))
    end)

    describe('initialize()', function()
        it('returns the instance', function()
            assert.is.equal(e:initialize(), e)
        end)
    end)

    describe('load()', function()
        it('does not error', function()
            assert.has_no.errors(function()
                e:load()
            end)
        end)
    end)

    describe('update()', function()
        it('calls update() on the top scene', function()
            local scene = e:newScene('test')
            e:pushScene(scene)
            spy.on(scene, 'update')
            e:update(0.1)
            assert.spy(scene.update).was.called()
        end)
        it('calls update() on multiple scenes in stack', function()
            local scene1 = e:newScene('test1')
            e:pushScene(scene1)
            spy.on(scene1, 'update')
            local scene2 = e:newScene('test2')
            e:pushScene(scene2)
            e:update(0.1)
            assert.spy(scene1.update).was.called()
        end)
        it("when engine is configured for dynamic steps it passes dt to the scene's update()", function()
            local scene = e:newScene('test')
            e:pushScene(scene)
            spy.on(scene, 'update')
            local dt = 0.1
            e:update(dt)
            assert.spy(scene.update).was.called_with(match._, dt)
        end)
        describe('when engine is configured for fixed steps', function()
            it('and dt is less than the fixed step update() is not called for the scene', function()
                e:importConfig({updateStep=0.2})
                local scene = e:newScene('test')
                e:pushScene(scene)
                spy.on(scene, 'update')
                local dt = 0.1
                e:update(dt)
                assert.spy(scene.update).was_not.called()
            end)
            it('and dt is equal to the fixed step amount the scene update() is called with the fixed dt', function()
                local dt = 0.2
                e:importConfig({updateStep=dt})
                local scene = e:newScene('test')
                e:pushScene(scene)
                spy.on(scene, 'update')
                e:update(dt)
                assert.spy(scene.update).was.called_with(match._, dt)
            end)
            it('and dt is greater than the fixed step amount the scene update() is called with the fixed dt', function()
                e:importConfig({updateStep=0.2})
                local scene = e:newScene('test')
                e:pushScene(scene)
                spy.on(scene, 'update')
                e:update(0.3)
                assert.spy(scene.update).was.called_with(match._, 0.2)
            end)
            it('and dt is greater than twice the fixed step amount, the scene update() is called multiple times', function()
                e:importConfig({updateStep=0.2})
                local scene = e:newScene('test')
                e:pushScene(scene)
                spy.on(scene, 'update')
                e:update(0.5)
                assert.spy(scene.update).was.called(2)
            end)
        end)
    end)

    describe('draw()', function()
        it('calls draw() on the top scene', function()
            local scene = e:newScene('test')
            e:pushScene(scene)
            spy.on(scene, 'draw')
            e:draw()
            assert.spy(scene.draw).was.called()
        end)
        it('calls draw() on multiple scenes in stack', function()
            local scene1 = e:newScene('test1')
            e:pushScene(scene1)
            spy.on(scene1, 'draw')
            local scene2 = e:newScene('test2')
            e:pushScene(scene2)
            e:draw()
            assert.spy(scene1.draw).was.called()
        end)
    end)

    describe('keypressed()', function()
        it('calls keypressed() on the top scene', function()
            local scene = e:newScene('test')
            e:pushScene(scene)
            spy.on(scene, 'keypressed')
            e:keypressed('', '', false)
            assert.spy(scene.keypressed).was.called()
        end)
    end)

    describe('keyreleased()', function()
        it('calls keyreleased() on the top scene', function()
            local scene = e:newScene('test')
            e:pushScene(scene)
            spy.on(scene, 'keyreleased')
            e:keyreleased('', '')
            assert.spy(scene.keyreleased).was.called()
        end)
    end)

    describe('newScene()', function()
        it('when not passed a class, returns a new Scene instance', function()
            local scene = e:newScene('test')
            assert.is.instanceOf(scene, Scene)
        end)
        it('when passed a class, returns a new instance of that class', function()
            local TestScene = Scene:subclass('TestScene')
            local scene = e:newScene('test', TestScene)
            assert.is.instanceOf(scene, TestScene)
        end)
        it('registers the new scene to the engine with the passed id', function()
            local sceneId = 'test'
            local scene = e:newScene(sceneId)
            assert.is.equal(scene, e:getScene(sceneId))
        end)
    end)

    describe('registerScene()', function()
        it('registers the scene', function()
            local scene = Scene(e)
            e:registerScene('test', scene)
            assert.is.equal(scene, e:getScene('test'))
        end)
        it('returns the engine', function()
            assert.is.equal(e, e:registerScene('test'))
        end)
    end)

    describe('unregisterScene()', function()
        it('unregisters an existing registered scene', function()
            local scene = Scene(e)
            e:registerScene('test', scene)
            e:unregisterScene('test')
            assert.is.False(e:sceneExists('test'))
        end)
        it('returns the engine', function()
            assert.is.equal(e, e:unregisterScene('test'))
        end)
    end)

    describe('sceneExists()', function()
        it('returns true if the scene is registered', function()
            local scene = Scene(e)
            e:registerScene('test', scene)
            assert.is.True(e:sceneExists('test'))
        end)
        it('returns false if the scene is not registered', function()
            assert.is.False(e:sceneExists('test'))
        end)
    end)

    describe('getScene()', function()
        it('returns the registered scene', function()
            local scene = Scene(e)
            e:registerScene('test', scene)
            assert.is.equal(scene, e:getScene('test'))
        end)
        it('errors if scene is not registered', function()
            assert.has.errors(function()
                e:getScene('test')
            end)
        end)
    end)

    describe('getSceneStackSize()', function()
        it('returns 0 if no scenes are on the stack', function()
            assert.is.equal(0, e:getSceneStackSize())
        end)
        it('returns 1 if one scene is on the stack', function()
            e:pushScene(Scene(e))
            assert.is.equal(1, e:getSceneStackSize())
        end)
        it('returns number of scenes added to the stack', function()
            e:pushScene(Scene(e))
            e:pushScene(Scene(e))
            assert.is.equal(2, e:getSceneStackSize())
        end)
    end)

    describe('sceneExistsAtIndex()', function()
        it('returns true if a scene exists at the specified index', function()
            e:pushScene(Scene(e))
            assert.is.True(e:sceneExistsAtIndex(1))
        end)
        it('returns false if the scene does not exist', function()
            assert.is.False(e:sceneExistsAtIndex(1))
        end)
    end)

    describe('getTopScene()', function()
        it('returns the top scene', function()
            local scene = Scene(e)
            e:pushScene(scene)
            assert.is.equal(scene, e:getTopScene())
        end)
    end)

    describe('getSceneFromTop()', function()
        it('when passed nothing returns the top scene', function()
            local scene = Scene(e)
            e:pushScene(scene)
            assert.is.equal(scene, e:getSceneFromTop())
        end)
        it('returns the scene at the offset from the top of the stack', function()
            local scene = Scene(e)
            e:pushScene(scene)
            e:pushScene(Scene(e))
            assert.is.equal(scene, e:getSceneFromTop(1))
        end)
    end)

    describe('getSceneAtIndex()', function()
        it('returns the scene at the stack index number (bottom to top)', function()
            local scene = Scene(e)
            e:pushScene(scene)
            assert.is.equal(scene, e:getSceneAtIndex(1))
        end)
    end)

    describe('pushScene()', function()
        it('returns the engine', function()
            assert.is.equal(e, e:pushScene(Scene(e)))
        end)
        it('when passed a scene instance adds it to the stack', function()
            local scene = Scene(e)
            e:pushScene(scene)
            assert.is.equal(scene, e:getTopScene())
        end)
        it('when passed a scene id adds that scene to the stack', function()
            local scene = e:newScene('test')
            e:pushScene('test')
            assert.is.equal(scene, e:getTopScene())
        end)
        it('adds scene on top of existing scenes in the stack', function()
            e:pushScene(Scene(e))
            local scene = Scene(e)
            e:pushScene(scene)
            assert.is.equal(scene, e:getTopScene())
        end)
    end)

    describe('popScene()', function()
        it('returns the top scene', function()
            local scene = Scene(e)
            e:pushScene(scene)
            assert.is.equal(scene, e:popScene())
        end)
    end)

    describe('isSceneRegistered()', function()
        it('returns scene id if scene is registered', function()
            local scene = Scene(e)
            e:registerScene('test', scene)
            assert.is.equal('test', e:isSceneRegistered(scene))
        end)
        it('returns nothing if scene is not registered', function()
            assert.is.Nil(e:isSceneRegistered(Scene(e)))
        end)
    end)

    describe('swapScene()', function()
        it('adds scene to top of stack', function()
            e:pushScene(Scene(e))
            local scene = Scene(e)
            e:swapScene(scene)
            assert.is.equal(scene, e:getTopScene())
        end)
        it('adds scene registered to id to the top of stack', function()
            e:pushScene(Scene(e))
            local scene = e:newScene('test')
            e:swapScene('test')
            assert.is.equal(scene, e:getTopScene())
        end)
        it('returns the top scene', function()
            local scene = Scene(e)
            e:pushScene(scene)
            assert.is.equal(scene, e:swapScene(Scene(e)))
        end)
    end)

    describe('attach()', function()
        it('allows engine callbacks to be called from LOVE callbacks', function()
            local e = Engine()
            e:pushScene(Scene(e))
            e:attach()

            spy.on(e, 'load')
            love.load()
            assert.spy(e.load).was.called()
            e.load:revert()

            spy.on(e, 'update')
            love.update(1)
            assert.spy(e.update).was.called()
            e.update:revert()

            spy.on(e, 'draw')
            love.draw()
            assert.spy(e.draw).was.called()
            e.draw:revert()

            spy.on(e, 'keypressed')
            love.keypressed('','',false)
            assert.spy(e.keypressed).was.called()
            e.keypressed:revert()

            spy.on(e, 'keyreleased')
            love.keyreleased('','')
            assert.spy(e.keyreleased).was.called()
            e.keyreleased:revert()
        end)
        it('once complete, original LOVE callbacks are still called', function()
            local e = Engine()
            e:pushScene(Scene(e))
            local initCallbacks = {
                load=spy.on(love, 'load'),
                update=spy.on(love, 'update'),
                draw=spy.on(love, 'draw'),
                keypressed=spy.on(love, 'keypressed'),
                keyreleased=spy.on(love, 'keyreleased')
            }
            e:attach()

            love.load()
            assert.spy(initCallbacks.load).was.called()
            initCallbacks.load:revert()

            love.update(1)
            assert.spy(initCallbacks.update).was.called()
            initCallbacks.update:revert()

            love.draw()
            assert.spy(initCallbacks.draw).was.called()
            initCallbacks.draw:revert()

            love.keypressed('','',false)
            assert.spy(initCallbacks.keypressed).was.called()
            initCallbacks.keypressed:revert()

            love.keyreleased('','')
            assert.spy(initCallbacks.keyreleased).was.called()
            initCallbacks.keyreleased:revert()
        end)
    end)

    describe('detach()', function()
        it('prevents engine callbacks from being called through LOVE', function()
            local e = Engine()
            e:attach()
            e:detach()

            spy.on(e, 'load')
            love.load()
            assert.spy(e.load).was_not.called()
            e.load:revert()

            spy.on(e, 'update')
            love.update(1)
            assert.spy(e.update).was_not.called()
            e.update:revert()

            spy.on(e, 'draw')
            love.draw()
            assert.spy(e.draw).was_not.called()
            e.draw:revert()

            spy.on(e, 'keypressed')
            love.keypressed('','',false)
            assert.spy(e.keypressed).was_not.called()
            e.keypressed:revert()

            spy.on(e, 'keyreleased')
            love.keyreleased('','')
            assert.spy(e.keyreleased).was_not.called()
            e.keyreleased:revert()    
        end)
        it('allows original LOVE callbacks to be called', function()
            local e = Engine()
            local initCallbacks = {
                load=spy.on(love, 'load'),
                update=spy.on(love, 'update'),
                draw=spy.on(love, 'draw'),
                keypressed=spy.on(love, 'keypressed'),
                keyreleased=spy.on(love, 'keyreleased')
            }
            e:attach()
            e:detach()
            
            love.load()
            assert.spy(initCallbacks.load).was.called()
            initCallbacks.load:revert()

            love.update(1)
            assert.spy(initCallbacks.update).was.called()
            initCallbacks.update:revert()

            love.draw()
            assert.spy(initCallbacks.draw).was.called()
            initCallbacks.draw:revert()

            love.keypressed('','',false)
            assert.spy(initCallbacks.keypressed).was.called()
            initCallbacks.keypressed:revert()

            love.keyreleased('','')
            assert.spy(initCallbacks.keyreleased).was.called()
            initCallbacks.keyreleased:revert()        
        end)
    end)

    describe('usePlugin()', function()
        it('applies plugin to the engine', function()
            local plugin = function(engine)
                engine.test = 'test'
            end
            e:usePlugin(plugin)
            assert.is.equal(e.test, 'test')
        end)
    end)

    describe('registerComponentClass()', function()

    end)

    describe('componentClassExists()', function()
    
    end)

    describe('getComponentClass()', function()
    
    end)

    describe('registerSystemClass()', function()
    
    end)

    describe('systemClassExists()', function()
    
    end)

    describe('getSystemClass()', function()
    
    end)

    describe('registerDataClass()', function()
        
    end)

    describe('dataClassExists()', function()
    
    end)

    describe('getDataClass()', function()
    
    end)

    describe('mergeData()', function()
        it('copies string data to target', function()
            source = {foo='bar'}
            target = {}
            e:mergeData(source, target)
            assert.is.equal(target.foo, 'bar')
        end)
        it('copies boolean data to target', function()
            source = {foo=true}
            target = {}
            e:mergeData(source, target)
            assert.is.equal(target.foo, true)
        end)
        it('copies number data to target', function()
            source = {foo=2}
            target = {}
            e:mergeData(source, target)
            assert.is.equal(target.foo, 2)
        end)
        it('ignores metatable values', function()
            local source = {}
            local sourceMT = {foo='bar'}
            sourceMT.__index = sourceMT
            setmetatable(source, sourceMT)
            target = {}
            e:mergeData(source, target)
            assert.is.Nil(target.foo)
        end)
        it('ignores keys that are functions', function()
            local k = function() end
            local source = {}
            source[k] = 'bar'
            target = {}
            e:mergeData(source, target)
            assert.is.Nil(target[k])
        end)
        it('ignores keys that are tables', function()
            local k = {}
            local source = {}
            source[k] = 'bar'
            target = {}
            e:mergeData(source, target)
            assert.is.Nil(target[k])
        end)
        it('ignores "class" keys', function()
            local source = {class='Test'}
            local target = {}
            e:mergeData(source, target)
            assert.is.Nil(target.class)
        end)
        it('ignores self references', function()
            local source = {}
            source.self = source
            local target = {}
            e:mergeData(source, target)
            assert.is.Nil(target.self)
        end)
        it('ignores function values', function()
            local source = {foo=function() end}
            local target = {}
            e:mergeData(source, target)
            assert.is.Nil(target.foo)
        end)
        it('does not copy __class entries to target', function()
            local source = {__class='Test'}
            local target = {}
            e:mergeData(source, target)
            assert.is.Nil(target.__class)
        end)
        it('ignores keys starting with "_"', function()
            local source = {_private='foo'}
            local target = {}
            e:mergeData(source, target)
            assert.is.Nil(target._private)
        end)
        it('ignores references to classes', function()
            local source = {sceneClass=Scene}
            local target = {}
            e:mergeData(source, target)
            assert.is.Nil(target.sceneClass)
        end)
        it('copies table to target', function()
            local source = {foo={}}
            local target = {}
            e:mergeData(source, target)
            assert.is.True(type(target.foo) == 'table')
        end)
        it('target table entry is not the same as the source entry', function()
            local foo = {}
            local source = {foo=foo}
            local target = {}
            e:mergeData(source, target)
            assert.is_not.equal(source.foo, target.foo)
        end)
        it('recursively copies table data', function()
            local foo = {
                bar={
                    baz='bleh'
                }
            }
            local source = {foo=foo}
            local target = {}
            e:mergeData(source, target)
            assert.is.equal(target.foo.bar.baz, 'bleh')
        end)
        it('with convertToObjects true, converts source tables with __class to data objects', function()
            local source = {v={__class='TestClass', x=1, y=2, z=3}}
            local target = {}
            e:mergeData(source, target, true)
            assert.is.instanceOf(target.v, TestClass)
        end)
        it('with convertToObjects false, does not convert source tables with __class to data objects', function()
            local source = {v={__class='TestClass', x=1, y=2, z=3}}
            local target = {}
            e:mergeData(source, target, false)
            assert.is_not.instanceOf(target.v, TestClass)
        end)
    end)

    describe('importData()', function()
        it('imports JSON strings', function()
            local result = e:importData('{"foo": "bar"}')
            assert.is.equal(result.foo, 'bar')
        end)
        it('imports bitser binary data', function()
            local t = {foo='bar'}
            local data = bitser.dumps(t)
            local result = e:importData(data)
            assert.is.equal(result.foo, 'bar')
        end)
        --TODO: should have a better way to mock the love calls, so that we
        --could check the file read logic paths.
    end)

    describe('exportData()', function()
        it('exports lua strings', function()
            local source = {foo='bar'}
            local result = e:exportData(source, 's', 'lua')
            assert.is.equal(result, 'return {\n  ["foo"] = "bar",\n}\n')
        end)
        it('exports json strings', function()
            local source = {foo='bar'}
            local result = e:exportData(source, 's', 'json')
            assert.is.equal(result, '{\n  "foo":"bar"\n}')
        end)
        it('exports bitser binary strings', function()
            local source = {foo='bar'}
            local result = e:exportData(source, 's', 'bin')
            local result = bitser.loads(result)
            assert.is.same(source, result)
        end)
    end)

    describe('importConfig()', function()
        it('merges data into engine config', function()
            local config = {updateStep=0.1}
            e:importConfig(config)
            assert.is.equal(e.config.updateStep, 0.1)
        end)
    end)
end)